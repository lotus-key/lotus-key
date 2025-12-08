# Design: Fix Simple Telex Behavior

## Context

Simple Telex is a variant of Telex that disables certain key transformations to reduce accidental conversions. However, the current implementation is too aggressive and blocks transformations that should work.

OpenKey has two Simple Telex variants (Simple Telex 1 and 2). LotusKey currently only implements one, equivalent to Simple Telex 1.

## Goals

- Match OpenKey's Simple Telex 1 behavior exactly
- Fix horn transformations (`ow → ơ`, `uw → ư`) - pattern matching runs regardless of Simple Telex
- Only block standalone `w → ư`
- Fix bracket key handling (pass through as literal)

## Non-Goals

- Implement Simple Telex 2
- Change any Telex behavior

## Decisions

### Decision 1: Allow all pattern-based horn transformations

**What**: Modify `handleSimpleTelexWKey()` to allow horn transformation for `ow → ơ` and `uw → ư`. Only block standalone `w → ư`.

**Why**: OpenKey's pattern matching runs first regardless of Simple Telex mode. Simple Telex only blocks the fallback standalone `w → ư` conversion.

**Implementation**:
```swift
private func handleSimpleTelexWKey(context: String, state: inout InputMethodState) -> InputTransformation? {
    let lower = context.lowercased()

    // ow → ơ (horn works - pattern matching runs regardless of Simple Telex)
    if lower.hasSuffix("o") {
        return InputTransformation(type: .modifier(.horn), category: .horn)
    }

    // uw → ư (horn works - pattern matching runs regardless of Simple Telex)
    if lower.hasSuffix("u") {
        return InputTransformation(type: .modifier(.horn), category: .horn)
    }

    // aw → ă (breve works)
    if lower.hasSuffix("a") {
        return InputTransformation(type: .modifier(.breve), category: .breve)
    }

    // Standalone w - no transformation (ONLY this is blocked)
    return nil
}
```

### Decision 2: Block bracket key transformation

**What**: Override bracket handling in SimpleTelexInputMethod to return `nil` (pass through).

**Why**: OpenKey's line 1541 shows bracket keys cause word break in Simple Telex modes.

**Implementation**:
```swift
public func processCharacter(...) -> InputTransformation? {
    // Block bracket keys - pass through as literal
    if char == "[" || char == "]" {
        return nil
    }
    
    // ... rest of logic
}
```

### Decision 3: Update isSpecialKey

**What**: Override `isSpecialKey()` to return `false` for bracket keys.

**Why**: OpenKey's `IS_SPECIALKEY` macro excludes brackets for Simple Telex modes.

**Implementation**:
```swift
public func isSpecialKey(_ character: Character) -> Bool {
    let char = character.lowercased().first ?? character
    // Brackets are NOT special in Simple Telex
    if char == "[" || char == "]" {
        return false
    }
    return telex.isSpecialKey(character)
}
```

## Alternatives Considered

### Alternative 1: Implement pattern matching in InputMethod

**Rejected**: This would require duplicating the complex vowel pattern tables from OpenKey. The current architecture keeps pattern matching in the engine, which is cleaner.

### Alternative 2: Add "uo" as special case in engine

**Rejected**: The fix belongs in SimpleTelexInputMethod since it's specific to Simple Telex behavior. The engine already handles "uo" pattern correctly when it receives the horn transformation.

## Risks / Trade-offs

1. **Risk**: Changing Simple Telex behavior may affect existing users
   - **Mitigation**: The change makes behavior match OpenKey, which is the expected reference

## Test Cases

```swift
// Horn transformations work
func testSimpleTelexOWHorn()   // ow → ơ
func testSimpleTelexUWHorn()   // uw → ư
func testSimpleTelexCow()      // cow → cơ
func testSimpleTelexThuong()   // thuowng → thương
func testSimpleTelexDuong()    // duowng → dương

// Standalone w blocked
func testSimpleTelexStandaloneWNoConversion()  // w → w (not ư)

// Breve works
func testSimpleTelexAWBreve()  // aw → ă

// Brackets pass through
func testSimpleTelexBracketPassthrough()      // [ → [, ] → ]
func testSimpleTelexBracketNotSpecialKey()    // isSpecialKey("[") → false
```

## Migration Plan

No migration needed - this is a bug fix to match expected behavior.
