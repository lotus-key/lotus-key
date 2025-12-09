## 1. Storage Layer
- [x] 1.1 Add `switchLanguageHotkey` key to `SettingsKey` enum
- [x] 1.2 Add `switchLanguageHotkey: UInt32` property to `SettingsStore` (bitfield format)
- [x] 1.3 Register default value (Ctrl+Space = `0x8131`) in `registerDefaults()`
- [x] 1.4 Add hotkey to `resetToDefaults()` method

## 2. Settings UI
- [x] 2.1 Create `ShortcutPicker` SwiftUI component with preset options
- [x] 2.2 Add "Shortcut" section to `SettingsView` general tab
- [x] 2.3 Display current shortcut in human-readable format (e.g., "⌃Space")
- [x] 2.4 Implement shortcut recording for custom combinations

## 3. Integration
- [x] 3.1 Subscribe to `switchLanguageHotkey` changes in `AppDelegate`
- [x] 3.2 Update `HotkeyDetector` when setting changes
- [x] 3.3 Load saved hotkey on app launch

## 4. Testing
- [x] 4.1 Unit test hotkey persistence (save/load bitfield)
- [x] 4.2 Test preset shortcuts detection
- [x] 4.3 Test settings change propagation to HotkeyDetector
