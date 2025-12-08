# Tasks: Fix Simple Telex Behavior

## 1. Fix SimpleTelexInputMethod

- [x] 1.1 Add bracket key handling to return `nil` (pass through as literal)
- [x] 1.2 Allow horn transformations (`ow → ơ`, `uw → ư`) - only block standalone `w → ư`
- [x] 1.3 Override `isSpecialKey()` to return `false` for bracket keys

## 2. Update Tests

- [x] 2.1 Update bracket tests to expect literal passthrough
- [x] 2.2 Update `testSimpleTelexOWHorn` and `testSimpleTelexUWHorn` to expect horn transformation
- [x] 2.3 Add `testSimpleTelexCow` for `cow → cơ`
- [x] 2.4 Add `testSimpleTelexThuong` and `testSimpleTelexDuong` for full words
- [x] 2.5 Add `testSimpleTelexBracketNotSpecialKey`
- [x] 2.6 Add `testSimpleTelexOWWUndo` and `testSimpleTelexUWWUndo` for horn undo

## 3. Verification

- [x] 3.1 Run all Simple Telex tests (24 tests pass)
- [x] 3.2 Run full test suite (275+ tests pass)
- [x] 3.3 Manual verification with LotusKey app (if applicable)
