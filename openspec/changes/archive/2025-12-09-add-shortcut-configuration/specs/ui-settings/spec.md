## ADDED Requirements

### Requirement: Shortcut Configuration

The system SHALL provide UI to configure the language toggle shortcut.

#### Scenario: Display shortcut section
- **WHEN** user accesses General settings tab
- **THEN** a "Shortcut" section is displayed
- **AND** current shortcut is shown in human-readable format (e.g., "⌃Space")

#### Scenario: Preset shortcut selection
- **WHEN** user clicks on shortcut picker
- **THEN** preset options are displayed:
  - Ctrl+Space (default)
  - Cmd+Space
  - Ctrl+Shift+Space
  - Option+Space

#### Scenario: Apply shortcut change
- **WHEN** user selects a different shortcut
- **THEN** setting is saved to UserDefaults with key `LotusKeySwitchLanguageHotkey`
- **AND** `HotkeyDetector` is updated immediately
- **AND** new shortcut takes effect without app restart

#### Scenario: Shortcut persistence
- **WHEN** application launches
- **THEN** saved shortcut is loaded from UserDefaults
- **AND** `HotkeyDetector` is configured with the saved hotkey

#### Scenario: Default shortcut
- **WHEN** no shortcut is configured (first launch)
- **THEN** default shortcut is Ctrl+Space

#### Scenario: Reset shortcut to default
- **WHEN** user resets settings to defaults
- **THEN** shortcut is reset to Ctrl+Space

---

## MODIFIED Requirements

### Requirement: Settings Panel

The system SHALL provide a settings panel for configuration.

#### Scenario: Open settings panel
- **WHEN** user selects "Settings..." from menu
- **THEN** settings window is displayed

#### Scenario: Input method settings
- **WHEN** user accesses input method settings
- **THEN** options for Telex, Simple Telex are available

#### Scenario: Spelling settings grouped
- **WHEN** user accesses General settings tab
- **THEN** spelling options are grouped in a dedicated "Spelling" section

#### Scenario: Spelling master toggle
- **WHEN** user toggles "Enable spell checking"
- **THEN** spell checking is enabled/disabled system-wide
- **AND** sub-options (restore if invalid) become enabled/disabled accordingly

#### Scenario: Restore if invalid word setting
- **WHEN** user enables "Restore keys if invalid word"
- **AND** spell checking is enabled
- **THEN** engine restores original keystrokes when word is invalid at word boundary

#### Scenario: Restore setting disabled state
- **WHEN** spell checking is disabled
- **THEN** "Restore keys if invalid word" toggle is visually disabled
- **AND** user cannot interact with it

#### Scenario: Ctrl bypass help text
- **WHEN** user views spelling settings
- **THEN** help text indicates "(Hold Ctrl to temporarily disable)"

#### Scenario: Feature toggles
- **WHEN** user accesses feature settings
- **THEN** options include: Quick Telex, Smart Switch, auto-capitalization

#### Scenario: Shortcut configuration
- **WHEN** user accesses shortcut settings
- **THEN** language switch hotkey can be customized via picker with presets
