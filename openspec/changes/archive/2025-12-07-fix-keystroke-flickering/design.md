# Design: Fix Keystroke Flickering

## Architecture Overview

The fix requires changes to the engine's result generation logic without altering the fundamental architecture. The key insight is distinguishing between "character append" and "character transformation" operations.

```
┌─────────────────────────────────────────────────────────────────┐
│                     KeyboardEventHandler                         │
│  ┌─────────────┐    ┌──────────────────────────────────────┐   │
│  │ CGEventTap  │───▶│ handleKeyDown()                       │   │
│  └─────────────┘    │                                        │   │
│                     │  ┌────────────────────────────────┐   │   │
│                     │  │ engine.processKey()             │   │   │
│                     │  │                                  │   │   │
│                     │  │  ┌─────────────────────────┐   │   │   │
│                     │  │  │ Input: keyCode, char    │   │   │   │
│                     │  │  └───────────┬─────────────┘   │   │   │
│                     │  │              ▼                  │   │   │
│                     │  │  ┌─────────────────────────┐   │   │   │
│                     │  │  │ processCharacter()      │   │   │   │
│                     │  │  │ - Check Quick Telex     │   │   │   │
│                     │  │  │ - Check Input Method    │   │   │   │
│                     │  │  │ - Apply transformation  │   │   │   │
│                     │  │  └───────────┬─────────────┘   │   │   │
│                     │  │              ▼                  │   │   │
│                     │  │  ┌─────────────────────────┐   │   │   │
│                     │  │  │ generateResult() ◀──────┼───┼───┼── FIX HERE
│                     │  │  │ - Decide: passThrough   │   │   │   │
│                     │  │  │   vs replace            │   │   │   │
│                     │  │  └───────────┬─────────────┘   │   │   │
│                     │  │              ▼                  │   │   │
│                     │  │  ┌─────────────────────────┐   │   │   │
│                     │  │  │ Output:                 │   │   │   │
│                     │  │  │ .passThrough OR         │   │   │   │
│                     │  │  │ .replace(n, text)       │   │   │   │
│                     │  │  └─────────────────────────┘   │   │   │
│                     │  └────────────────────────────────┘   │   │
│                     └──────────────────────────────────────┘   │
│                                      │                          │
│                                      ▼                          │
│                     ┌──────────────────────────────────────┐   │
│                     │ Result Handling:                      │   │
│                     │ .passThrough → return event           │   │
│                     │ .replace → injectBackspaces + inject  │   │
│                     └──────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## Key Design Decisions

### Decision 1: When to Pass Through vs Replace

**Pass through** (no backspace, let keystroke go to app):
- Character added to end of buffer without any transformation
- No tone mark applied
- No modifier applied
- No Quick Telex expansion
- No grammar correction

**Replace** (send backspaces + new text):
- Tone mark applied (s, f, r, x, j keys trigger tone)
- Modifier applied (a, e, o, w, d keys trigger circumflex/horn/breve/stroke)
- Quick Telex expansion (cc → ch, gg → gi, etc.)
- Grammar auto-correction (ưo → ươ when ending consonant typed)
- Undo operation (restore original characters)

### Decision 2: Tracking Transformation State

The current `wasTransformed` parameter in `generateResult()` is already used but not fully utilized. We need to ensure it accurately reflects whether ANY transformation occurred during processing.

Current transformation sources that should set `wasTransformed = true`:
1. `applyTransformation()` - tone marks, modifiers, undo
2. `applyQuickTelexExpansion()` - Quick Telex
3. `checkGrammar()` - grammar auto-correction

### Decision 3: Result Generation Logic

**Current logic (problematic):**
```swift
if backspaces == 0 && newLength == 1 && !wasTransformed {
    return .passThrough
}
return .replace(backspaceCount: backspaces, replacement: newOutput)
```

**New logic (proposed):**
```swift
// Case 1: No transformation, just appending a character
// The character will be displayed by the system, we just track it internally
if !wasTransformed {
    return .passThrough
}

// Case 2: Transformation occurred - need to replace
// Send backspaces to delete old chars, then send new transformed text
return .replace(backspaceCount: backspaces, replacement: newOutput)
```

## Edge Cases

### Edge Case 1: First Character of Word
- Buffer empty → append char → `.passThrough`
- Already handled correctly

### Edge Case 2: Non-Special Keys After Special Keys
- Buffer: "hà" → user types "n" → append "n" → `.passThrough`
- The "n" is not a special key, no transformation

### Edge Case 3: Special Key Without Target
- Buffer: "h" → user types "s" (tone key)
- No vowel to apply tone → add "s" as literal → `.passThrough`
- Already handled: `wasTransformed = false` when no vowel found

### Edge Case 4: Grammar Auto-Correction
- Buffer: "thưo" → user types "n" → grammar corrects to "thươn"
- This IS a transformation → `.replace(4, "thươn")`
- `checkGrammar()` returns true → `wasTransformed = true`

### Edge Case 5: Quick Telex
- Buffer: "c" → user types "c" → expands to "ch"
- This IS a transformation → `.replace(1, "ch")`

## Implementation Approach

### Phase 1: Update generateResult() Logic

Modify the condition to check only `wasTransformed`:

```swift
private func generateResult(previousLength: Int, wasTransformed: Bool = false) -> EngineResult {
    let newOutput = buffer.toUnicodeString()
    let newLength = newOutput.count

    // If no transformation occurred, the keystroke can pass through
    // The system will display the character, we just track it internally
    if !wasTransformed {
        previousOutputLength = newLength
        return .passThrough
    }

    // Transformation occurred - need to replace text
    let backspaces = previousOutputLength
    previousOutputLength = newLength
    return .replace(backspaceCount: backspaces, replacement: newOutput)
}
```

### Phase 2: Fix addCharacterToBuffer() - CRITICAL

**BUG FOUND**: The current `addCharacterToBuffer()` does NOT pass `wasTransformed` to `generateResult()`. This MUST be fixed alongside Phase 1, otherwise grammar correction will break.

Current code (BROKEN with new logic):
```swift
private func addCharacterToBuffer(_ char: Character) -> EngineResult {
    // ...
    if isGrammarTriggerConsonant(char.lowercased().first) {
        if checkGrammar() {
            _ = buffer.refreshTonePosition()
        }
    }
    return generateResult(previousLength: oldLength)  // ❌ Missing wasTransformed!
}
```

Fixed code:
```swift
private func addCharacterToBuffer(_ char: Character) -> EngineResult {
    let oldLength = buffer.toUnicodeString().count
    buffer.append(char)
    _ = buffer.refreshTonePosition()

    var wasTransformed = false

    if isGrammarTriggerConsonant(char.lowercased().first) {
        wasTransformed = checkGrammar()
        if wasTransformed {
            _ = buffer.refreshTonePosition()
        }
    }

    return generateResult(previousLength: oldLength, wasTransformed: wasTransformed)
}
```

### Phase 3: Verify Other Transformation Paths

Verify all transformation paths correctly set `wasTransformed = true`:

| Path | Status | Notes |
|------|--------|-------|
| applyTransformation() | ✅ Correct | Returns wasTransformed flag |
| applyToneMark() | ✅ Correct | Returns true if mark applied |
| applyModifier() | ✅ Correct | Returns true if modifier applied |
| applyQuickTelexExpansion() | ✅ Correct | Always passes `wasTransformed: true` |
| addCharacterToBuffer() | ❌ **FIX NEEDED** | Must capture checkGrammar() result |

## Testing Strategy

### Unit Tests

1. **Normal keystroke passthrough**: Verify "abc" types without replace
2. **Tone mark transformation**: Verify "as" produces replace for "á"
3. **Modifier transformation**: Verify "aa" produces replace for "â"
4. **Quick Telex**: Verify "cc" produces replace for "ch"
5. **Grammar correction**: Verify "thưon" produces replace for "thươn"
6. **Mixed input**: Verify complex sequences work correctly

### Integration Tests

1. **Flicker detection**: Automated test to count backspace events
2. **Text output verification**: Final text matches expected

### Manual Tests

1. Type common words and observe no flickering
2. Type with tone marks and verify correct transformation
3. Test in various applications (Terminal, TextEdit, Chrome)

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking existing transformation logic | High | Comprehensive test coverage |
| Performance regression | Medium | Measure event callback timing |
| Edge cases missed | Medium | Test with real Vietnamese text corpus |
| Application compatibility | Low | Test in various apps |

## Rollback Plan

If issues are discovered post-implementation:
1. Revert to previous `generateResult()` logic
2. The change is isolated to one function, easy to rollback
