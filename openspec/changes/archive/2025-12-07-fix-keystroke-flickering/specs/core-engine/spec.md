# core-engine

## MODIFIED Requirements

### Requirement: Processing Result Communication

The system SHALL communicate processing results to the platform layer with precise instructions for text manipulation, using pass-through for simple character appends and replace only for actual transformations.

#### Scenario: Simple character append (passthrough)
- **WHEN** a character is added to the buffer
- **AND** no transformation occurs (no tone mark, modifier, Quick Telex, or grammar correction)
- **THEN** the result indicates passthrough (no action needed)
- **AND** the original keystroke is allowed to pass through to the application
- **AND** the internal buffer is updated to track the character

#### Scenario: Process result with character replacement
- **WHEN** Vietnamese processing transforms input (tone mark, modifier, Quick Telex expansion, or grammar correction)
- **THEN** the result includes: number of backspaces to send, array of new Unicode characters to output
- **AND** the platform layer deletes old characters and injects the new transformed text

#### Scenario: Do nothing result
- **WHEN** the input does not require Vietnamese processing (e.g., English mode, control key held)
- **THEN** the result indicates no action needed
- **AND** original keystroke passes through

---

## ADDED Requirements

### Requirement: Transformation Detection

The system SHALL accurately detect when a keystroke causes actual text transformation versus simple character append.

#### Scenario: Tone mark transformation
- **WHEN** a tone key (s, f, r, x, j in Telex) is pressed
- **AND** there is a valid vowel to apply the tone to
- **THEN** transformation is detected
- **AND** the result is a replace operation

#### Scenario: Modifier transformation
- **WHEN** a modifier key (a, e, o, w, d in Telex) is pressed
- **AND** it matches a valid vowel pattern (e.g., "aa" → "â")
- **THEN** transformation is detected
- **AND** the result is a replace operation

#### Scenario: Quick Telex expansion
- **WHEN** a Quick Telex pattern is matched (e.g., "cc" → "ch")
- **THEN** transformation is detected
- **AND** the result is a replace operation

#### Scenario: Grammar auto-correction
- **WHEN** a grammar trigger consonant is typed after a partial horn pattern (e.g., "thưo" + "n")
- **AND** the grammar check corrects the pattern (e.g., "ưo" → "ươ")
- **THEN** transformation is detected
- **AND** the result is a replace operation

#### Scenario: No transformation for normal consonant
- **WHEN** a non-special key is pressed (e.g., consonants like h, l, m, n)
- **AND** no Quick Telex pattern matches
- **AND** no grammar correction is needed
- **THEN** no transformation is detected
- **AND** the result is passthrough

#### Scenario: No transformation for standalone vowel
- **WHEN** a vowel key is pressed (a, e, i, o, u)
- **AND** it does not match any modifier pattern (e.g., first "a" in "a", not second "a" in "aa")
- **THEN** no transformation is detected
- **AND** the result is passthrough
