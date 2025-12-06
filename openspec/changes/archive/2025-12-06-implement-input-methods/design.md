## Context

Input method layer cần hoàn thiện với undo mechanism, Simple Telex variant, và bracket key shortcuts. Tham khảo OpenKey C++ implementation (`Engine.cpp`, `Vietnamese.cpp`) để đảm bảo tương thích hành vi.

Reference: OpenKey source code analysis:
- Undo logic: `Engine.cpp:778-806` (insertMark), `Engine.cpp:813-831` (insertD), `Engine.cpp:871-984` (insertW)
- Simple Telex: `Engine.cpp:1187` (vSimpleTelex1 check)
- Bracket keys: `Engine.cpp:1065-1073`
- tempDisableKey: `Engine.cpp:95`, `Engine.cpp:789`, `Engine.cpp:819`

## Goals / Non-Goals

**Goals:**
- Implement undo transformation matching OpenKey behavior exactly
- Add Simple Telex variant (w không chuyển ơ/ư, standalone w không thành ư)
- Implement bracket key shortcuts (`[` → ơ, `]` → ư)
- Integrate Quick Telex vào engine processing pipeline
- Implement tempDisableKey mechanism to prevent re-transformation after undo
- Maintain clean separation between InputMethod và Engine

**Non-Goals:**
- VNI input method (separate change proposal)
- Quick Start/End Consonants: f→ph, j→gi, g→ng, etc. (separate change proposal)
- VIQR input method
- Custom key mapping configuration
- Input method hot-reload

## Decisions

### 1. Undo State Tracking

**Decision:** Track undo state trong InputMethod protocol thay vì Engine.

**Rationale:**
- Mỗi input method có undo rules riêng
- Engine chỉ cần biết transformation result, không cần biết undo logic
- Dễ test từng input method độc lập

**Implementation:**
```swift
protocol InputMethod {
    // Existing
    func processCharacter(_ character: Character, context: String) -> InputTransformation?

    // New: check if this char would undo last transformation
    func wouldUndo(_ character: Character, context: String, lastTransform: TransformationType?) -> Bool
}
```

### 2. Undo Detection Logic

**Decision:** Detect undo bằng cách so sánh current char với last transformation type.

**Rules:**
| Last Transform | Undo Trigger | Result |
|---------------|--------------|--------|
| circumflex (aa→â) | 'a' | â→aa |
| horn (ow→ơ) | 'w' | ơ→ow |
| breve (aw→ă) | 'w' | ă→aw |
| stroke (dd→đ) | 'd' | đ→dd |
| tone (as→á) | same tone key | á→a |

**Edge case:** `aaa` sequence
1. `a` → buffer: [a]
2. `a` → circumflex applied → buffer: [â]
3. `a` → undo detected → buffer: [a, a]

### 2.1 Temp Disable Key After Undo

**Decision:** After undo, temporarily disable the same key to prevent immediate re-transformation.

**OpenKey Reference:** `Engine.cpp:95` declares `tempDisableKey`, set to `true` at lines 789, 819, 854, 896, 966.

**Behavior:**
```
User types: a a a a
Step 1: 'a' → buffer: [a]
Step 2: 'a' → circumflex → buffer: [â], tempDisableKey = false
Step 3: 'a' → undo → buffer: [a, a], tempDisableKey = true
Step 4: 'a' → tempDisableKey=true, skip transform → buffer: [a, a, a]
Step 5: (word break) → tempDisableKey = false
```

**Implementation:**
```swift
struct InputMethodState {
    var tempDisabledKey: Character? = nil

    mutating func disableKey(_ char: Character) {
        tempDisabledKey = char
    }

    mutating func reset() {
        tempDisabledKey = nil
    }

    func isDisabled(_ char: Character) -> Bool {
        return tempDisabledKey == char
    }
}
```

### 3. Simple Telex W Key Handling

**Decision:** Simple Telex reuses Telex code với flag để skip horn transformation AND standalone w conversion.

**OpenKey Reference:** `Engine.cpp:1187`
```cpp
if (data == KEY_W && vInputType != vSimpleTelex1) {
    checkForStandaloneChar(data, isCaps, KEY_U);  // Only Telex does w→ư
}
```

**Key differences from Telex:**
1. `ow` stays as `ow` (no → ơ)
2. `uw` stays as `uw` (no → ư)
3. `aw` → `ă` (breve still works!)
4. Standalone `w` stays as `w` (no → ư)

```swift
struct SimpleTelexInputMethod: InputMethod {
    private let telex = TelexInputMethod()

    func processCharacter(_ char: Character, context: String) -> InputTransformation? {
        let lower = char.lowercased().first!

        // W key special handling for Simple Telex
        if lower == "w" {
            let contextLower = context.lowercased()

            // Case 1: w after o/u → no transformation (literal w)
            if contextLower.hasSuffix("o") || contextLower.hasSuffix("u") {
                return nil  // Pass through as literal
            }

            // Case 2: Standalone w → no transformation (unlike Telex)
            // Only 'aw' → 'ă' is allowed
            if !contextLower.hasSuffix("a") {
                return nil  // Pass through as literal
            }
        }

        // Everything else delegates to Telex
        return telex.processCharacter(char, context: context)
    }
}
```

### 3.1 Bracket Key and Standalone W Shortcuts

**Decision:** Support `[` → ơ, `]` → ư, and standalone `w` → ư with context-aware rules.

**OpenKey Reference:** `Engine.cpp:995-1040`, `Vietnamese.cpp:375-389`

**Important context rules from OpenKey:**
```cpp
// Characters that BLOCK standalone transformation
vector<Uint16> _standaloneWbad = {
    KEY_W, KEY_E, KEY_Y, KEY_F, KEY_J, KEY_K, KEY_Z
};

// Double consonants that ALLOW standalone transformation
vector<vector<Uint16>> _doubleWAllowed = {
    {KEY_T, KEY_R}, {KEY_T, KEY_H}, {KEY_C, KEY_H}, {KEY_N, KEY_H},
    {KEY_N, KEY_G}, {KEY_K, KEY_H}, {KEY_G, KEY_I}, {KEY_P, KEY_H}, {KEY_G, KEY_H}
};
```

**Detailed behavior:**

| Context | `w` (Telex) | `[` | `]` |
|---------|-------------|-----|-----|
| Word start (empty) | ư | ơ | ư |
| After single consonant (b, c, d...) | ư | ơ | ư |
| After `w, e, y, f, j, k, z` | literal w | literal [ | literal ] |
| After vowel | ư (transforms vowel) | literal [ | literal ] |
| After double consonant (tr, th, ch...) | ư | ơ | ư |
| `u` + `[` special case | - | uơ | - |

**Special case `u[`:** OpenKey has explicit handling (Engine.cpp:1007-1010):
```cpp
if (_index > 0 && CHR(_index-1) == KEY_U && keyWillReverse == KEY_O) {
    insertKey(keyWillReverse, isCaps);
    reverseLastStandaloneChar(keyWillReverse, isCaps);
}
```
This means `u[` → `uơ` (not `u[`).

**Simplified Implementation (MVP):**

For initial implementation, we simplify the rules:
- `[` or `]` at word start → transform to ơ/ư
- `[` or `]` after consonant → transform to ơ/ư
- `[` or `]` after vowel → literal (except `u[` → `uơ`)
- Standalone `w` follows same rules

```swift
extension TelexInputMethod {
    private static let standaloneBlockers: Set<Character> = ["w", "e", "y", "f", "j", "k", "z"]

    func processBracketKey(_ char: Character, context: String) -> InputTransformation? {
        guard char == "[" || char == "]" else { return nil }

        // Empty context → transform
        guard let lastChar = context.last?.lowercased().first else {
            let replacement: Character = char == "[" ? "ơ" : "ư"
            return InputTransformation(type: .standaloneHorn, backspaceCount: 0, replacement: String(replacement))
        }

        // Special case: u[ → uơ
        if char == "[" && lastChar == "u" {
            return InputTransformation(type: .standaloneHorn, backspaceCount: 0, replacement: "ơ")
        }

        // After vowel → literal (except special case above)
        if Vietnamese.vowels.contains(lastChar) {
            return nil
        }

        // After blocker character → literal
        if Self.standaloneBlockers.contains(lastChar) {
            return nil
        }

        // Otherwise → transform
        let replacement: Character = char == "[" ? "ơ" : "ư"
        return InputTransformation(type: .standaloneHorn, backspaceCount: 0, replacement: String(replacement))
    }
}
```

### 4. Quick Telex Integration Point

**Decision:** Quick Telex xử lý TRƯỚC input method trong Engine.processCharacter().

**Flow:**
```
User types 'c' → buffer: [c]
User types 'c' → QuickTelex detects 'cc' → replace with 'ch' → buffer: [c, h]
User types 'a' → normal processing → buffer: [c, h, a]
```

**Implementation in Engine:**
```swift
private func processCharacter(_ char: Character) -> EngineResult {
    // 1. Check Quick Telex first
    if quickTelex.isEnabled,
       let lastChar = buffer.last?.baseCharacter,
       let expansion = quickTelex.processShortcut(char, previousCharacter: lastChar) {
        // Remove last char, add expansion
        return applyQuickTelexExpansion(expansion)
    }

    // 2. Then input method processing
    // ... existing code ...
}
```

### 5. Input Method Registry

**Decision:** Simple static registry, không cần dynamic loading.

```swift
enum InputMethodRegistry {
    static let telex = TelexInputMethod()
    static let simpleTelex = SimpleTelexInputMethod()

    static func get(_ id: String) -> (any InputMethod)? {
        switch id {
        case "telex": return telex
        case "simple-telex": return simpleTelex
        default: return nil
        }
    }

    static var `default`: any InputMethod { telex }
    static var availableIDs: [String] { ["telex", "simple-telex"] }
}
```

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Undo state mismatch với OpenKey | Test với cùng input sequences, compare output |
| Quick Telex + undo interaction | Quick Telex expansion không có undo (design choice) |
| Performance overhead từ undo tracking | Minimal - chỉ track last transform type |
| Bracket keys conflict với other apps | Only transform at word start/after consonant |
| tempDisableKey reset timing | Reset on word break, method switch, or new session |

## Open Questions

- ~~Simple Telex 1 vs 2 khác nhau không?~~ → Giống nhau trong OpenKey, chỉ cần 1 implementation
- ~~Bracket keys có cần không?~~ → Có, OpenKey hỗ trợ `[` → ơ, `]` → ư
- ~~tempDisableKey hoạt động thế nào?~~ → Disable same key after undo, reset on word break

## Test Matrix

| Input | Telex | Simple Telex | Expected Behavior |
|-------|-------|--------------|-------------------|
| `aa` | â | â | Circumflex |
| `aaa` | aa | aa | Undo circumflex |
| `aaaa` | aaa | aaa | tempDisableKey prevents re-transform |
| `ow` | ơ | ow | Simple Telex no horn |
| `uw` | ư | uw | Simple Telex no horn |
| `aw` | ă | ă | Both have breve |
| `w` (standalone) | ư | w | Simple Telex no standalone |
| `[` (start) | ơ | ơ | Bracket shortcut |
| `]` (start) | ư | ư | Bracket shortcut |
| `b[` | bơ | bơ | After consonant |
| `a[` | a[ | a[ | Bracket after vowel = literal |
| `u[` | uơ | uơ | Special case: u + [ = uơ |
| `w[` | w[ | w[ | Blocked after w |
| `e]` | e] | e] | Blocked after e (blocker char) |
| `tr[` | trơ | trơ | After double consonant |
