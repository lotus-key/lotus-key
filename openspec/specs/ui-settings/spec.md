# ui-settings Specification

## Purpose
Defines the user interface components including the menu bar integration, settings panel, and application lifecycle management.
## Requirements
### Requirement: Menu Bar Integration

The system SHALL provide a status bar menu for quick access to features.

#### Scenario: Status bar icon display
- **WHEN** application is running
- **THEN** status bar icon is displayed showing current language (V/E)

#### Scenario: Menu bar menu access
- **WHEN** user clicks status bar icon
- **THEN** menu is displayed with input options

#### Scenario: Quick language toggle
- **WHEN** user selects language toggle from menu
- **THEN** input language switches immediately

#### Scenario: Input method selection
- **WHEN** user selects input method from submenu
- **THEN** input method changes (Telex, Simple Telex)

---

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

#### Scenario: Hotkey configuration
- **WHEN** user accesses hotkey settings
- **THEN** language switch hotkey can be customized

---

### Requirement: About Window

The system SHALL provide application information.

#### Scenario: Display about window
- **WHEN** user selects "About" from menu
- **THEN** window displays: app name, version, copyright, credits

---

### Requirement: Configuration Persistence

The system SHALL persist all user settings.

#### Scenario: Settings key consistency
- **WHEN** settings are read or written
- **THEN** both SwiftUI `@AppStorage` and `SettingsStore` use the same UserDefaults keys
- **AND** keys follow the pattern `VnIme{SettingName}` (e.g., `VnImeSpellCheckEnabled`)

#### Scenario: Settings saved automatically
- **WHEN** user changes any setting
- **THEN** setting is saved to UserDefaults immediately

#### Scenario: Settings restored on launch
- **WHEN** application launches
- **THEN** all settings are restored from UserDefaults

#### Scenario: Default settings
- **WHEN** settings are not found
- **THEN** sensible defaults are applied:
  - Language: Vietnamese
  - Input method: Telex
  - Spell check: enabled
  - Restore if wrong spelling: enabled

---

### Requirement: Application Lifecycle

The system SHALL manage application lifecycle properly.

#### Scenario: Background app mode
- **WHEN** dock icon is hidden in settings
- **THEN** application runs as menu bar only (`.accessory` activation policy)
- **AND** application does not appear in Dock or app switcher

#### Scenario: Dock icon mode
- **WHEN** dock icon is enabled in settings
- **THEN** application appears in Dock (`.regular` activation policy)
- **AND** application appears in app switcher (Cmd+Tab)

#### Scenario: Dock icon toggle takes effect immediately
- **WHEN** user toggles dock icon setting
- **THEN** dock visibility changes immediately without restart

#### Scenario: Login item registration
- **WHEN** launch at login is enabled
- **THEN** application registers with `SMAppService.mainAppService`
- **AND** application appears in System Settings > General > Login Items

#### Scenario: Login item unregistration
- **WHEN** launch at login is disabled
- **THEN** application unregisters from `SMAppService.mainAppService`
- **AND** application is removed from System Settings > General > Login Items

#### Scenario: Login item requires approval
- **WHEN** registration returns `.requiresApproval` status
- **THEN** application guides user to System Settings to approve

#### Scenario: Login item state sync on launch
- **WHEN** application launches
- **THEN** setting is synced with actual system state
- **AND** UI reflects the true registration status

#### Scenario: Graceful exit
- **WHEN** user quits application
- **THEN** event tap is cleaned up
- **AND** settings are saved
- **AND** login item registration state is preserved

---

### Requirement: System Notifications

The system SHALL respond to system notifications.

#### Scenario: System wake handling
- **WHEN** system wakes from sleep
- **THEN** event tap is re-initialized if needed

#### Scenario: System sleep handling
- **WHEN** system goes to sleep
- **THEN** event tap is properly suspended

#### Scenario: Space change handling
- **WHEN** user switches to different macOS space
- **THEN** new typing session is started

### Requirement: App Lifecycle Manager

The system SHALL provide a dedicated manager for application lifecycle operations.

#### Scenario: Launch at login management
- **WHEN** `AppLifecycleManager.setLaunchAtLogin(true)` is called
- **THEN** application is registered as login item via `SMAppService`
- **AND** errors are thrown if registration fails

#### Scenario: Launch at login status check
- **WHEN** `AppLifecycleManager.launchAtLoginStatus` is accessed
- **THEN** current `SMAppService.Status` is returned (`.enabled`, `.notRegistered`, `.requiresApproval`)

#### Scenario: Dock icon management
- **WHEN** `AppLifecycleManager.setDockIconVisible(true)` is called
- **THEN** `NSApp.setActivationPolicy(.regular)` is invoked

#### Scenario: Dock icon hidden
- **WHEN** `AppLifecycleManager.setDockIconVisible(false)` is called
- **THEN** `NSApp.setActivationPolicy(.accessory)` is invoked

#### Scenario: Thread safety
- **WHEN** lifecycle methods are called
- **THEN** execution happens on main thread (enforced by `@MainActor`)

### Requirement: Restore If Wrong Spelling Setting

The system SHALL provide a setting to control restore-on-invalid behavior.

#### Scenario: Setting persistence
- **WHEN** user changes "Restore keys if invalid word" setting
- **THEN** setting is saved to UserDefaults with key `VnImeRestoreIfWrongSpelling`
- **AND** setting is restored on next app launch

#### Scenario: Default value
- **WHEN** app is first launched (no settings exist)
- **THEN** "Restore keys if invalid word" defaults to enabled (true)

#### Scenario: Engine integration
- **WHEN** setting is changed
- **THEN** engine's `restoreIfWrongSpelling` property is updated
- **AND** change takes effect immediately (no restart required)

#### Scenario: Reset to defaults
- **WHEN** user resets settings to defaults
- **THEN** "Restore keys if invalid word" is reset to enabled (true)

