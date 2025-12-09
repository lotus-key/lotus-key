# Change: Add Configurable Shortcut for Vietnamese Toggle

## Why
Users need the ability to customize the keyboard shortcut for toggling Vietnamese input on/off. The current default (`Ctrl+Space`) may conflict with system shortcuts or user preferences. This aligns with the existing spec scenario "Hotkey configuration" in ui-settings which is not yet implemented.

## What Changes
- Add shortcut configuration UI in Settings panel (new "Shortcut" section)
- Add `switchLanguageHotkey` setting to `SettingsStore` for persistence (stored as bitfield)
- Integrate with existing `HotkeyDetector` to apply user-configured hotkey
- Provide preset shortcuts (Ctrl+Space, Cmd+Space, Ctrl+Shift+Space) plus custom recording

## Impact
- Affected specs: `ui-settings` (add shortcut configuration UI)
- Affected code:
  - `Sources/LotusKey/Storage/SettingsStore.swift` - add hotkey setting
  - `Sources/LotusKey/UI/SettingsView.swift` - add shortcut picker UI
  - `Sources/LotusKey/App/AppDelegate.swift` - apply hotkey on settings change
