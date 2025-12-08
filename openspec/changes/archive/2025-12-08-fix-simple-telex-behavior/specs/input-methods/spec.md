# input-methods Spec Delta

## MODIFIED Requirements

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
