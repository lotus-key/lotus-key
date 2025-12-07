# i18n Specification

## Purpose
TBD - created by archiving change add-i18n-support. Update Purpose after archive.
## Requirements
### Requirement: Language Support

The system SHALL support English and Vietnamese user interface languages with both automatic and manual selection.

#### Scenario: Default system language detection
- **GIVEN** app language setting is "Follow System" (default)
- **AND** user's macOS system language is set
- **WHEN** LotusKey launches
- **THEN** UI displays in the system's preferred language if supported
- **AND** falls back to English if language is not supported

#### Scenario: Manual English selection
- **GIVEN** user has selected "English" in app settings
- **WHEN** LotusKey launches (after restart)
- **THEN** UI displays in English regardless of system language

#### Scenario: Manual Vietnamese selection
- **GIVEN** user has selected "Tiếng Việt" in app settings
- **WHEN** LotusKey launches (after restart)
- **THEN** UI displays in Vietnamese regardless of system language

#### Scenario: Vietnamese locale display
- **GIVEN** active language is Vietnamese (vi)
- **WHEN** user views any UI element
- **THEN** all labels, buttons, and help text display in Vietnamese

#### Scenario: English locale display
- **GIVEN** active language is English (en)
- **WHEN** user views any UI element
- **THEN** all labels, buttons, and help text display in English

---

### Requirement: Language Selection UI

The system SHALL provide a language picker in Settings.

#### Scenario: Language picker display
- **WHEN** user opens Settings > Behavior section
- **THEN** language picker displays with options:
  - "Follow System" / "Theo hệ thống" (default)
  - "English"
  - "Tiếng Việt"

#### Scenario: Language change requires restart
- **WHEN** user changes language setting
- **THEN** restart prompt is displayed
- **AND** setting is saved immediately
- **AND** new language takes effect after restart

#### Scenario: Restart prompt options
- **WHEN** restart prompt is displayed
- **THEN** user can choose "Restart Now" or "Later"
- **AND** "Restart Now" relaunches the app
- **AND** "Later" dismisses prompt (change applies on next launch)

#### Scenario: Language setting persistence
- **WHEN** user selects a language
- **THEN** setting is saved to UserDefaults with key `LotusKeyAppLanguage`
- **AND** setting persists across app launches

---

### Requirement: Settings View Localization

The system SHALL localize all settings panel elements.

#### Scenario: Tab names localized
- **WHEN** user opens settings window
- **THEN** tab names display in current locale:
  - English: "General", "About"
  - Vietnamese: "Chung", "Giới thiệu"

#### Scenario: Section headers localized
- **WHEN** user views General tab
- **THEN** section headers display in current locale:
  - English: "Input", "Spelling", "Behavior", "Compatibility"
  - Vietnamese: "Kiểu gõ", "Chính tả", "Hệ thống", "Tương thích"

#### Scenario: Toggle labels localized
- **WHEN** user views settings toggles
- **THEN** toggle labels display in current locale
- **AND** associated help text displays in current locale

#### Scenario: Input method picker localized
- **WHEN** user views input method picker
- **THEN** picker label displays "Input Method" (en) or "Kiểu gõ" (vi)
- **AND** input method names remain unchanged (Telex, Simple Telex)

---

### Requirement: Menu Bar Localization

The system SHALL localize all menu bar items.

#### Scenario: Language toggle menu item
- **WHEN** user clicks status bar icon
- **THEN** language toggle displays in current locale:
  - When Vietnamese active: "Tiếng Việt" / "Vietnamese"
  - When English active: "Tiếng Anh" / "English"

#### Scenario: Settings menu item
- **WHEN** user views menu bar menu
- **THEN** settings item displays "Settings..." (en) or "Bảng điều khiển..." (vi)

#### Scenario: Quit menu item
- **WHEN** user views menu bar menu
- **THEN** quit item displays "Quit LotusKey" (en) or "Thoát" (vi)

---

### Requirement: About Section Localization

The system SHALL localize the About tab content.

#### Scenario: App description localized
- **WHEN** user views About tab
- **THEN** description displays:
  - English: "Vietnamese Input Method for macOS"
  - Vietnamese: "Bộ gõ Tiếng Việt dành cho macOS"

#### Scenario: Version format localized
- **WHEN** user views About tab
- **THEN** version string displays in current locale format

#### Scenario: App name unchanged
- **WHEN** user views About tab
- **THEN** app name displays as "LotusKey" regardless of locale

---

### Requirement: Accessibility Permission Localization

The system SHALL localize accessibility permission prompts.

#### Scenario: Permission description localized
- **WHEN** accessibility permission view is displayed
- **THEN** description text displays in current locale

#### Scenario: Permission button labels localized
- **WHEN** accessibility permission view is displayed
- **THEN** button labels display in current locale

---

### Requirement: Help Text Localization

The system SHALL localize all help text and tooltips.

#### Scenario: Quick Telex help localized
- **WHEN** user hovers over Quick Telex help icon
- **THEN** help text displays in current locale:
  - English: "cc → ch, gg → gi\nkk → kh, ngg → ngh\nqq → qu"
  - Vietnamese: "cc → ch, gg → gi\nkk → kh, ngg → ngh\nqq → qu"

#### Scenario: Restore invalid words help localized
- **WHEN** user hovers over Restore Invalid Words help icon
- **THEN** help text displays in current locale explaining the feature
- **AND** includes Control key bypass instruction

#### Scenario: Smart switch help localized
- **WHEN** user hovers over Smart Language Switch help icon
- **THEN** help text displays in current locale:
  - English: "Remembers Vietnamese or English preference for each application."
  - Vietnamese: "Ghi nhớ ngôn ngữ theo từng ứng dụng."

---

### Requirement: String Catalog Format

The system SHALL use Swift String Catalogs for localization.

#### Scenario: String catalog file exists
- **WHEN** project is built
- **THEN** `Localizable.xcstrings` file exists in Resources

#### Scenario: All strings extracted
- **WHEN** string catalog is compiled
- **THEN** all user-facing strings have corresponding keys
- **AND** Xcode automatically extracts keys from SwiftUI string literals

#### Scenario: SwiftUI automatic localization
- **WHEN** SwiftUI views use string literals
- **THEN** strings are automatically treated as `LocalizedStringKey`
- **AND** translated values are retrieved from string catalog

#### Scenario: AppKit explicit localization
- **WHEN** AppKit components (menu bar) need localized strings
- **THEN** code uses `String(localized:)` initializer
- **AND** keys match entries in string catalog

---

### Requirement: Vietnamese Terminology Consistency

The system SHALL use consistent Vietnamese terminology matching OpenKey conventions.

#### Scenario: Core terms match OpenKey
- **WHEN** Vietnamese locale is active
- **THEN** key terms match OpenKey:
  - "Kiểu gõ" for input method
  - "Kiểm tra chính tả" for spell checking
  - "Gõ nhanh" for Quick Telex
  - "Chuyển chế độ thông minh" for Smart Switch

#### Scenario: System terms match OpenKey
- **WHEN** Vietnamese locale is active
- **THEN** system terms match OpenKey:
  - "Khởi động cùng macOS" for Launch at Login
  - "Hiện biểu tượng trên thanh Dock" for Show in Dock
  - "Bảng điều khiển" for Settings/Control Panel

---

