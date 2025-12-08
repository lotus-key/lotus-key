# input-methods Specification

## Purpose
Defines the input method protocols and implementations (Telex, Simple Telex) for Vietnamese text entry, including transformation rules and Quick Telex shortcuts.
## Requirements
### Requirement: Telex Input Method

The system SHALL support the Telex input method for Vietnamese text entry.

#### Scenario: Vowel transformation with double letter
- **WHEN** user types 'aa', 'ee', or 'oo'
- **THEN** the system transforms to 'â', 'ê', or 'ô' respectively

#### Scenario: Horn and breve transformation with 'w'
- **WHEN** user types 'aw', 'ow', or 'uw'
- **THEN** the system transforms to 'ă', 'ơ', or 'ư' respectively

#### Scenario: Stroke transformation for 'd'
- **WHEN** user types 'dd'
- **THEN** the system transforms to 'đ'

#### Scenario: Tone mark keys
- **WHEN** user types tone mark keys (s, f, r, x, j)
- **THEN** the system applies corresponding marks (sắc, huyền, hỏi, ngã, nặng)

#### Scenario: Remove mark with 'z'
- **WHEN** user types 'z' after a marked character
- **THEN** the system removes the tone mark

#### Scenario: Undo vowel transformation
- **WHEN** user types the same vowel transformation key three times (e.g., 'aaa')
- **THEN** the circumflex is removed and result is 'aa'

#### Scenario: Undo stroke transformation
- **WHEN** user types 'ddd' after 'đ' is formed
- **THEN** the stroke is removed and result is 'dd'

#### Scenario: Undo horn/breve transformation
- **WHEN** user types 'w' again after horn/breve is applied (e.g., 'aww')
- **THEN** the horn/breve is removed and result is 'aw'

#### Scenario: Undo tone mark
- **WHEN** user types the same tone key twice (e.g., 'ass' after 'á')
- **THEN** the tone mark is removed and result is 'as'

#### Scenario: Prevent re-transformation after undo
- **WHEN** user types the same key immediately after undo (e.g., 'aaaa')
- **THEN** the key is temporarily disabled and added as literal
- **AND** result is 'aaa' (not 'âa')

#### Scenario: Temp disable key reset on word break
- **WHEN** temp disable is active
- **AND** user types a word break (space, punctuation)
- **THEN** the temp disable is reset
- **AND** subsequent same key will transform again

#### Scenario: Standalone w to ư
- **WHEN** user types 'w' at word start or after consonant
- **THEN** the system transforms to 'ư'

#### Scenario: Bracket key left bracket to ơ
- **WHEN** user types '[' at word start or after consonant
- **THEN** the system transforms to 'ơ'

#### Scenario: Bracket key right bracket to ư
- **WHEN** user types ']' at word start or after consonant
- **THEN** the system transforms to 'ư'

#### Scenario: Bracket key after vowel is literal
- **WHEN** user types '[' or ']' after a vowel (except 'u')
- **THEN** the bracket is output as literal character

#### Scenario: Special case u bracket to uơ
- **WHEN** user types 'u' followed by '['
- **THEN** result is 'uơ' (special case)

#### Scenario: Standalone blocked after certain chars
- **WHEN** user types 'w', '[', or ']' after w, e, y, f, j, k, or z
- **THEN** the key is output as literal (no transformation)

---

### Requirement: Simple Telex Input Method

The system SHALL support Simple Telex variants with reduced key combinations. Simple Telex 1 and Simple Telex 2 have identical behavior.

#### Scenario: Simple Telex tone marks
- **WHEN** Simple Telex is selected
- **THEN** tone mark keys (s, f, r, x, j, z) work identically to Telex

#### Scenario: Simple Telex vowel transformation
- **WHEN** Simple Telex is selected
- **AND** user types 'aa', 'ee', or 'oo'
- **THEN** the system transforms to 'â', 'ê', or 'ô' (same as Telex)

#### Scenario: Simple Telex stroke transformation
- **WHEN** Simple Telex is selected
- **AND** user types 'dd'
- **THEN** the system transforms to 'đ' (same as Telex)

#### Scenario: Simple Telex W key no horn for single o
- **WHEN** Simple Telex is selected
- **AND** user types 'ow' (single 'o' not preceded by 'u')
- **THEN** 'w' is treated as literal character
- **AND** result is 'ow' (not 'ơ')

#### Scenario: Simple Telex W key no horn for single u
- **WHEN** Simple Telex is selected
- **AND** user types 'uw' (single 'u' not followed by 'o')
- **THEN** 'w' is treated as literal character
- **AND** result is 'uw' (not 'ư')

#### Scenario: Simple Telex uo pattern transformation
- **WHEN** Simple Telex is selected
- **AND** user types 'uow' (u followed by o, then w)
- **THEN** the system transforms to 'ươ' (horn applied to both)

#### Scenario: Simple Telex thuowng to thương
- **WHEN** Simple Telex is selected
- **AND** user types 'thuowng'
- **THEN** the system transforms to 'thương'

#### Scenario: Simple Telex breve with 'aw'
- **WHEN** Simple Telex is selected
- **AND** user types 'aw'
- **THEN** the system transforms to 'ă' (breve still works for 'a')

#### Scenario: Simple Telex standalone w is literal
- **WHEN** Simple Telex is selected
- **AND** user types 'w' at word start or after consonant
- **THEN** 'w' is output as literal (not transformed to 'ư')

#### Scenario: Simple Telex undo breve
- **WHEN** Simple Telex is selected
- **AND** user types 'aww' after 'ă' is formed
- **THEN** the breve is removed and result is 'aw'

#### Scenario: Simple Telex undo with temp disable
- **WHEN** Simple Telex is selected
- **AND** user types 'awww'
- **THEN** result is 'aww' (tempDisableKey prevents re-transformation)

#### Scenario: Simple Telex bracket keys pass through
- **WHEN** Simple Telex is selected
- **AND** user types '[' or ']'
- **THEN** the bracket character is output as literal (no transformation)
- **AND** bracket keys are not considered special keys

#### Scenario: Simple Telex bracket after vowel
- **WHEN** Simple Telex is selected
- **AND** user types 'a[' or 'o]'
- **THEN** result is 'a[' or 'o]' (literal passthrough)

### Requirement: Quick Telex Consonant Shortcuts

The system SHALL support Quick Telex shortcuts for common consonant combinations when enabled.

#### Scenario: Quick consonant 'cc' to 'ch'
- **WHEN** Quick Telex is enabled
- **AND** user types 'cc'
- **THEN** the system transforms to 'ch'

#### Scenario: Quick consonant 'gg' to 'gi'
- **WHEN** Quick Telex is enabled
- **AND** user types 'gg'
- **THEN** the system transforms to 'gi'

#### Scenario: Quick consonant 'nn' to 'ng'
- **WHEN** Quick Telex is enabled
- **AND** user types 'nn'
- **THEN** the system transforms to 'ng'

#### Scenario: All quick consonant mappings
- **WHEN** Quick Telex is enabled
- **THEN** the following shortcuts are available: cc→ch, gg→gi, kk→kh, nn→ng, pp→ph, qq→qu, tt→th

#### Scenario: Quick Telex disabled
- **WHEN** Quick Telex is disabled
- **AND** user types 'cc'
- **THEN** 'cc' is output as-is without transformation

---

### Requirement: Input Method Switching

The system SHALL allow switching between Telex and Simple Telex at runtime.

#### Scenario: Switch input method
- **WHEN** user changes input method
- **THEN** new session starts
- **AND** subsequent input uses new method rules

#### Scenario: Preserve language state on method switch
- **WHEN** input method is changed
- **THEN** Vietnamese/English language state is preserved

### Requirement: Input Method Registry

The system SHALL provide a centralized registry for available input methods.

#### Scenario: List available methods
- **WHEN** application queries available input methods
- **THEN** returns list containing Telex, Simple Telex

#### Scenario: Get method by identifier
- **WHEN** application requests input method by ID (e.g., "telex", "simple-telex")
- **THEN** returns the corresponding InputMethod instance

#### Scenario: Default method
- **WHEN** no input method preference is set
- **THEN** Telex is used as default

---

### Requirement: Quick Telex Engine Integration

The system SHALL integrate Quick Telex shortcuts into the input processing pipeline.

#### Scenario: Quick Telex in engine
- **WHEN** Quick Telex is enabled in settings
- **AND** user types a quick shortcut (e.g., 'cc')
- **THEN** engine transforms it to the expansion (e.g., 'ch')

#### Scenario: Quick Telex disabled passthrough
- **WHEN** Quick Telex is disabled in settings
- **AND** user types 'cc'
- **THEN** 'cc' is output without transformation

#### Scenario: Quick Telex with subsequent input
- **WHEN** user types 'cca' (quick telex + vowel)
- **THEN** result is 'cha'

