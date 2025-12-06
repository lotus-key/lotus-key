## ADDED Requirements

### Requirement: Grammar Auto-Adjust

The system SHALL automatically adjust vowel modifiers when syllable structure changes to ensure correct Vietnamese orthography for non-standard typing orders, following OpenKey's `checkGrammar()` behavior.

Note: Standard typing order (e.g., "thuowng" → "thương") already works via existing `applyModifier(.horn)` logic. This requirement handles edge cases.

#### Scenario: Auto-adjust "ưo" to "ươ" when followed by ending consonant

- **WHEN** user types a sequence where U has horn but O does not (e.g., "thưon" from "thuwon")
- **AND** a trigger consonant (n, c, i, m, p, t) is typed
- **THEN** the system automatically applies horn modifier to O as well
- **AND** the output reflects "ươ" (e.g., "thương")

#### Scenario: Auto-adjust "uơ" to "ươ" when followed by ending consonant

- **WHEN** user types a sequence where O has horn but U does not (e.g., "thuơn")
- **AND** a trigger consonant (n, c, i, m, p, t) is typed
- **THEN** the system automatically applies horn modifier to U as well
- **AND** the output reflects "ươ" (e.g., "thương")

#### Scenario: No adjustment when both vowels already have horn

- **WHEN** user types "ươ" explicitly (both U and O have horn)
- **AND** followed by ending consonant
- **THEN** the system does NOT double-apply modifiers
- **AND** the word remains as typed (XOR condition is false)

#### Scenario: No adjustment when neither vowel has horn

- **WHEN** user types "uo" without any horn modifier
- **AND** followed by ending consonant
- **THEN** the system does NOT auto-apply horn
- **AND** the word remains as "uon" (XOR condition is false)

#### Scenario: Grammar check after character insertion

- **WHEN** user adds a character to the buffer
- **AND** buffer has 3 or more characters
- **THEN** the system runs grammar checking
- **AND** adjusts modifiers if pattern matches

#### Scenario: Grammar check after backspace

- **WHEN** user presses backspace
- **AND** buffer still has 3 or more characters after removal
- **THEN** the system runs grammar checking
- **AND** adjustments are recalculated for remaining characters

---

### Requirement: Grammar Trigger Consonants

The system SHALL recognize specific consonants as grammar triggers that may require modifier adjustment on preceding vowels.

#### Scenario: Valid grammar trigger consonants

- **WHEN** checking for grammar adjustment
- **THEN** the following consonants trigger the check: n, c, i, m, p, t
- **AND** these match OpenKey's `checkGrammar()` trigger list

#### Scenario: Non-trigger characters

- **WHEN** a character that is NOT in the trigger list is added
- **THEN** no grammar adjustment is performed for that character
- **AND** existing modifiers remain unchanged

---

### Requirement: XOR Modifier Application

The system SHALL use XOR logic to determine when to auto-apply horn modifiers, preventing double-application.

#### Scenario: XOR condition true - one vowel has horn

- **WHEN** checking "uo" pattern
- **AND** U has horn but O does not (or vice versa)
- **THEN** horn is applied to both vowels
- **AND** result is "ươ"

#### Scenario: XOR condition false - both have horn

- **WHEN** checking "uo" pattern
- **AND** both U and O already have horn
- **THEN** no additional modifiers are applied
- **AND** result remains "ươ"

#### Scenario: XOR condition false - neither has horn

- **WHEN** checking "uo" pattern
- **AND** neither U nor O has horn
- **THEN** no modifiers are applied
- **AND** result remains "uo"

---

## MODIFIED Requirements

### Requirement: Dynamic Tone Repositioning

The system SHALL automatically reposition tone marks when syllable structure changes during typing, AND adjust vowel modifiers when grammar patterns are detected.

#### Scenario: Tone repositioning after adding ending consonant
- **WHEN** user adds an ending consonant after typing a vowel with tone
- **THEN** the system recalculates the correct tone position
- **AND** moves the tone to the correct vowel if needed
- **AND** checks for grammar auto-adjust patterns

#### Scenario: Tone repositioning after modifier application
- **WHEN** user applies a modifier (circumflex, horn) to a vowel
- **THEN** the system refreshes the tone position based on new structure
- **AND** checks for grammar auto-adjust patterns

#### Scenario: Combined tone and modifier adjustment
- **WHEN** grammar auto-adjust modifies vowel modifiers
- **THEN** the system also refreshes tone position
- **AND** ensures tone is on the correct vowel after adjustment
