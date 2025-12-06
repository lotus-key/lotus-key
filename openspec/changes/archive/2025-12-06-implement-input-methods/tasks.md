# Tasks: Implement Complete Input Methods

## 1. Telex Undo Mechanism

- [x] 1.1 Add `UndoContext` tracking to InputMethod protocol (last transformation type, original char)
- [x] 1.2 Add `tempDisabledKey` state to InputMethodState for preventing re-transformation
- [x] 1.3 Implement vowel transformation undo in TelexInputMethod (aaa → aa, eee → ee, ooo → oo)
- [x] 1.4 Implement stroke transformation undo (ddd → dd after đ)
- [x] 1.5 Implement horn/breve transformation undo (aww → aw, oww → ow, uww → uw)
- [x] 1.6 Implement tone mark undo in VietnameseEngine (same tone key twice removes tone)
- [x] 1.7 Implement tempDisableKey reset on word break
- [x] 1.8 Write tests for all undo scenarios (12+ tests):
  - `aa` → `â`
  - `aaa` → `aa`
  - `aaaa` → `aaa` (tempDisableKey)
  - `dd` → `đ`
  - `ddd` → `dd`
  - `aw` → `ă`
  - `aww` → `aw`
  - `ow` → `ơ`
  - `oww` → `ow`
  - `as` → `á`
  - `ass` → `as`
  - `aaaa ` + `aa` → `aaa â` (reset after space)

## 2. Bracket Key and Standalone W Shortcuts

- [x] 2.1 Add bracket key handling to TelexInputMethod (`[` → ơ, `]` → ư)
- [x] 2.2 Add standalone blocker list: `w, e, y, f, j, k, z`
- [x] 2.3 Implement context detection (transform at word start or after consonant)
- [x] 2.4 Pass through as literal when after vowel (except `u[` special case)
- [x] 2.5 Pass through as literal when after blocker characters
- [x] 2.6 Write tests for bracket key scenarios (9 tests):
  - `[` at start → `ơ`
  - `]` at start → `ư`
  - `b[` → `bơ` (after consonant)
  - `a[` → `a[` (literal after vowel)
  - `u]` → `u]` (literal after vowel)
  - `u[` → `uơ` (special case!)
  - `w[` → `w[` (literal after blocker)
  - `e]` → `e]` (literal after blocker - e is blocker AND vowel)
  - `tr[` → `trơ` (after double consonant)

## 3. Simple Telex Input Method

- [x] 3.1 Create SimpleTelexInputMethod.swift implementing InputMethod protocol
- [x] 3.2 Implement tone mark handling (identical to Telex: s, f, r, x, j, z)
- [x] 3.3 Implement vowel transformation (identical to Telex: aa, ee, oo)
- [x] 3.4 Implement stroke transformation (identical to Telex: dd)
- [x] 3.5 Implement W key special handling:
  - `ow` stays `ow` (no horn)
  - `uw` stays `uw` (no horn)
  - `aw` → `ă` (breve still works)
  - Standalone `w` stays `w` (no → ư)
- [x] 3.6 Implement undo mechanism (same as Telex)
- [x] 3.7 Implement bracket key shortcuts (same as Telex)
- [x] 3.8 Write tests for Simple Telex specific behavior (10+ tests):
  - `aa` → `â` (same as Telex)
  - `ow` → `ow` (no horn)
  - `uw` → `uw` (no horn)
  - `aw` → `ă` (breve works)
  - `aww` → `aw` (undo works)
  - `w` at start → `w` (no standalone conversion)
  - `bw` → `bw` (no conversion after consonant)
  - `[` at start → `ơ` (bracket works)
  - `]` at start → `ư` (bracket works)
  - `as` → `á` (tone works)

## 4. Input Method Registry

- [x] 4.1 Create InputMethodRegistry.swift with available methods list
- [x] 4.2 Implement method lookup by identifier (telex, simple-telex)
- [x] 4.3 Add default method property (Telex)
- [x] 4.4 Write tests for registry (4 tests):
  - List returns ["telex", "simple-telex"]
  - Get "telex" returns TelexInputMethod
  - Get "simple-telex" returns SimpleTelexInputMethod
  - Default is Telex

## 5. Quick Telex Engine Integration

- [x] 5.1 Add QuickTelex property to VietnameseEngine
- [x] 5.2 Integrate QuickTelex.processShortcut() into processCharacter flow (BEFORE input method)
- [x] 5.3 Handle backspace count correctly for quick shortcuts (delete 1, insert 2)
- [x] 5.4 Wire Quick Telex enable/disable to SettingsStore
- [x] 5.5 Write integration tests for Quick Telex in engine (6 tests):
  - `cc` → `ch` (enabled)
  - `cc` → `cc` (disabled)
  - `cca` → `cha`
  - `gg` → `gi`
  - `nn` → `ng`
  - `tt` → `th`

## 6. Validation

- [x] 6.1 Run `swift build` to verify compilation
- [x] 6.2 Run `swift test` to verify all tests pass (204 tests total, 48 new tests added)
- [x] 6.3 Manual verification: Compare behavior with OpenKey for test matrix in design.md
- [x] 6.4 Run `openspec validate implement-input-methods --strict`
