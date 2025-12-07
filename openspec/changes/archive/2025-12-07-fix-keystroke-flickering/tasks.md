# Tasks: Fix Keystroke Flickering

## Overview

Fix the keystroke flickering issue by modifying the engine's result generation logic to only send backspace+replace when actual transformation occurs.

---

## Task 1: Update generateResult() Logic

**Goal**: Modify result generation to pass through when no transformation occurred

**Changes**:

- [x] Update `generateResult()` in `VietnameseEngine.swift` to check only `wasTransformed`
- [x] Remove the `backspaces == 0 && newLength == 1` condition
- [x] Ensure `previousOutputLength` is updated correctly in both paths

**Code Change**:

```swift
// FROM:
if backspaces == 0 && newLength == 1 && !wasTransformed {
    return .passThrough
}
return .replace(backspaceCount: backspaces, replacement: newOutput)

// TO:
if !wasTransformed {
    return .passThrough
}
return .replace(backspaceCount: backspaces, replacement: newOutput)
```

**Validation**:

- [x] Existing tests pass
- [x] Manual test: Type "hello" - no flickering observed

**Dependencies**: None

---

## Task 2: Fix addCharacterToBuffer() to Pass wasTransformed

**Goal**: Ensure grammar correction triggers replace, simple appends pass through

**Problem**: Current code does NOT pass `wasTransformed` to `generateResult()` when grammar correction occurs. This will break grammar auto-correction with the new logic.

**Changes**:

- [x] Add `wasTransformed` variable to capture `checkGrammar()` result
- [x] Pass `wasTransformed` to `generateResult()` call

**Code Change**:

```swift
// FROM:
private func addCharacterToBuffer(_ char: Character) -> EngineResult {
    let oldLength = buffer.toUnicodeString().count
    buffer.append(char)
    _ = buffer.refreshTonePosition()

    if isGrammarTriggerConsonant(char.lowercased().first) {
        if checkGrammar() {
            _ = buffer.refreshTonePosition()
        }
    }

    return generateResult(previousLength: oldLength)  // ❌ Missing wasTransformed!
}

// TO:
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

**Validation**:

- [x] Unit test: `processString("con")` - passthrough, no replace operations
- [x] Unit test: `processString("thưon")` - replace for grammar correction to "thươn"
- [x] Unit test: Grammar correction still works correctly

**Dependencies**: Task 1

---

## Task 3: Add Unit Tests for Passthrough Behavior

**Goal**: Add tests to verify no unnecessary replacements

**Changes**:

- [x] Add test: Normal consonant/vowel sequence passes through
- [x] Add test: Verify backspace count is 0 for simple appends
- [x] Add test: Verify transformation keys still trigger replace
- [x] Add test: Grammar correction triggers replace

**Test Cases**:

| Input | Expected Result | Backspaces |
|-------|-----------------|------------|
| "hi" | passthrough for both chars | 0 |
| "con" | passthrough for all chars | 0 |
| "as" | replace for 's' (tone) | 1 |
| "aa" | replace for 2nd 'a' (circumflex) | 1 |
| "cc" | replace for 2nd 'c' (Quick Telex) | 1 |
| "thưon" | replace for 'n' (grammar) | 4 |

**Validation**:

- [x] All new tests pass
- [x] Code coverage for `generateResult()` is 100%

**Dependencies**: Task 1, Task 2

---

## Task 4: Add Integration Tests for Flicker Prevention

**Goal**: Verify end-to-end that flickering is eliminated

**Changes**:

- [x] Add test helper to count backspace injections
- [x] Add test: Typing "nước" results in minimal backspaces (only for transformations)
- [x] Add test: Typing "việt nam" tracks expected backspace count

**Validation**:

- [x] Tests demonstrate reduced backspace count vs. previous behavior

**Dependencies**: Task 1, Task 2, Task 3

---

## Task 5: Manual Testing and Edge Case Verification

**Goal**: Verify behavior in real applications

**Checklist**:

- [x] Test in Terminal.app
- [x] Test in TextEdit.app
- [x] Test in Chrome/Safari
- [x] Test in VS Code
- [x] Test Quick Telex (cc, gg, etc.)
- [x] Test tone marks (s, f, r, x, j)
- [x] Test modifiers (a, e, o, w, d after vowels)
- [x] Test grammar correction (thưon → thương)
- [x] Test restore-on-invalid-spelling

**Validation**:

- [x] No visible flickering in any tested application
- [x] All Vietnamese input features work correctly

**Dependencies**: Task 1-4

---

## Execution Order

```text
Task 1 (generateResult logic)
    │
    └──▶ Task 2 (addCharacterToBuffer FIX - CRITICAL)
             │
             └──▶ Task 3 (unit tests)
                      │
                      └──▶ Task 4 (integration tests)
                               │
                               └──▶ Task 5 (manual testing)
```

## Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| Grammar correction breaks | **HIGH** | Task 2 MUST be done with Task 1 |
| Buffer/screen mismatch | HIGH | Comprehensive test coverage |
| Edge cases missed | Medium | Manual testing in Task 5 |

## Estimated Effort

| Task | Effort | Parallelizable |
|------|--------|----------------|
| Task 1 | Small | No |
| Task 2 | Small | No (MUST follow Task 1) |
| Task 3 | Medium | No |
| Task 4 | Medium | No |
| Task 5 | Medium | Yes (after Task 4) |

**Total**: ~2-3 hours implementation + testing

## Technical Notes

### Unused Parameter

The `previousLength` parameter in `generateResult()` is never used - only the instance variable `previousOutputLength` is used. This is existing technical debt and not addressed in this change.
