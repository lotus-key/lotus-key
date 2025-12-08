# Change: Fix Simple Telex Behavior to Match OpenKey

## Why

Simple Telex implementation in LotusKey has behavioral differences from OpenKey that prevent common Vietnamese typing patterns from working correctly. The critical issue is that pattern-based transformations (`ow → ơ`, `uw → ư`) were incorrectly blocked - Simple Telex should ONLY block standalone `w → ư`, not pattern-based horn transformations.

## What Changes

1. **Fix horn transformations** - Allow `ow → ơ` and `uw → ư` (pattern matching runs regardless of Simple Telex mode). Only standalone `w → ư` should be blocked.
2. **Fix bracket key handling** - Bracket keys `[` and `]` should pass through as literal characters (cause word break) in Simple Telex, not transform to ơ/ư
3. **Fix isSpecialKey** - Return `false` for bracket keys in Simple Telex mode

## Impact

- Affected specs: `input-methods`
- Affected code:
  - `Sources/LotusKey/Core/InputMethods/SimpleTelexInputMethod.swift`
  - `Tests/LotusKeyTests/InputMethodTests.swift`
  - `Tests/LotusKeyTests/EngineTests.swift`

## Technical Analysis

### OpenKey Behavior (Reference)

From `Engine.cpp`:

1. **Pattern matching first** (line 1155-1180): Vowel patterns like `{KEY_O}` are matched regardless of Simple Telex mode, and `insertW()` is called.

2. **insertW handles "uo" specially** (line 899-910): When "uo" pattern detected, horn is applied to both vowels.

3. **Simple Telex only blocks fallback** (line 1187):
   ```cpp
   if (data == KEY_W && vInputType != vSimpleTelex1) {
       checkForStandaloneChar(data, isCaps, KEY_U);  // Only standalone blocked
   }
   ```

4. **Bracket keys cause word break** (line 1541):
   ```cpp
   if (IS_BRACKET_KEY(data) && (... || vSimpleTelex1 || vSimpleTelex2)) {
       // Word break - pass through as literal
   }
   ```

### Current LotusKey Bug (Fixed)

`handleSimpleTelexWKey()` was returning `nil` for ANY w after o/u:
```swift
if lower.hasSuffix("o") || lower.hasSuffix("u") {
    return nil  // BUG: blocks ALL horn transformations!
}
```

This incorrectly blocked ALL pattern-based horn transformations (`ow → ơ`, `uw → ư`), when Simple Telex should only block standalone `w → ư`.

**Fix**: Return horn transformation for `ow` and `uw` patterns, only return `nil` for standalone `w`.

## References

- OpenKey source: `OpenKey/Sources/OpenKey/engine/Engine.cpp`
- OpenKey data types: `OpenKey/Sources/OpenKey/engine/DataType.h`
- Original analysis in conversation
