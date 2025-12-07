# Proposal: Add i18n Support

## Change ID
`add-i18n-support`

## Summary
Add internationalization (i18n) support to LotusKey for both English and Vietnamese languages. The Vietnamese labels are referenced from OpenKey to maintain familiarity for Vietnamese users.

## Motivation
- LotusKey currently has hardcoded English UI strings in SwiftUI views
- Existing `Localizable.strings` file has Vietnamese translations but they are not used
- Vietnamese users expect native Vietnamese UI labels (referencing OpenKey's terminology)
- Supporting multiple languages improves accessibility and user experience

## Scope

### In Scope
- Implement Swift String Catalogs (`.xcstrings`) for modern localization (macOS 15+)
- Create English (`en`) and Vietnamese (`vi`) localizations
- Localize all UI components:
  - Settings window (tabs, sections, toggles, labels, help text)
  - Menu bar items
  - Accessibility permission view
  - About section
- Use OpenKey's Vietnamese terminology for consistency
- Support dual language selection:
  - **Automatic**: Follow system language (default)
  - **Manual**: User can override in Settings

### Out of Scope
- Additional languages beyond English and Vietnamese
- Localization of internal error messages or logs
- Runtime language switching without restart (due to mixed SwiftUI/AppKit architecture)

## Impact Analysis

### Files to Modify
- `Sources/LotusKey/UI/SettingsView.swift` - Replace hardcoded strings with localized keys, add language picker
- `Sources/LotusKey/UI/AccessibilityPermissionView.swift` - Localize permission text
- `Sources/LotusKey/App/AppDelegate.swift` - Localize menu bar items, apply language setting on launch
- `Sources/LotusKey/Storage/SettingsStore.swift` - Add `AppLanguage` enum and `appLanguage` setting
- `Sources/LotusKey/Resources/Localizable.strings` - Remove (migrate to xcstrings)

### Files to Create
- `Sources/LotusKey/Resources/Localizable.xcstrings` - String catalog with en/vi translations

### Affected Specs
- `ui-settings` - Add i18n requirements

## Design Decisions

### 1. String Catalogs vs Legacy .strings
**Decision**: Use Swift String Catalogs (`.xcstrings`)

**Rationale**:
- Native Xcode 15+ / Swift 5.9+ format
- Better tooling support in Xcode
- JSON-based format easier to review in PRs
- Automatic string extraction
- LotusKey targets macOS 15+ so compatibility is not an issue

### 2. Localization Key Naming Convention
**Decision**: Use English text as keys (SwiftUI default behavior)

**Rationale** (based on 2025 best practices):
- SwiftUI automatically treats string literals as `LocalizedStringKey`
- No need for explicit `String(localized:)` in most cases
- Code remains readable without separate key lookup
- String Catalogs handle key-to-translation mapping automatically
- Xcode extracts keys automatically during build

**Examples**:
```swift
// SwiftUI automatically localizes these:
Text("General")           // Key: "General" → "Chung" (vi)
Toggle("Quick Telex", ...) // Key: "Quick Telex" → "Gõ nhanh" (vi)

// For non-SwiftUI contexts:
String(localized: "Settings")
```

**Alternative considered**: Semantic dot-notation keys (`settings.general.title`)
- Pros: Better organization for translators
- Cons: Less readable code, requires manual key management
- Decision: English-as-key is simpler and aligns with Apple's recommended approach

### 3. Vietnamese Terminology (from OpenKey)
Key translations referencing OpenKey:

| English | Vietnamese (OpenKey) |
|---------|---------------------|
| Vietnamese | Tiếng Việt |
| English | Tiếng Anh |
| Input Method | Kiểu gõ |
| Spell Checking | Kiểm tra chính tả |
| Restore Invalid Words | Tự khôi phục phím với từ sai |
| Quick Telex | Gõ nhanh |
| Smart Language Switch | Chuyển chế độ thông minh |
| Launch at Login | Khởi động cùng macOS |
| Show in Dock | Hiện biểu tượng trên thanh Dock |
| Auto-capitalize | Viết hoa chữ cái đầu câu |
| Settings | Bảng điều khiển |
| About | Giới thiệu |
| Quit | Thoát |
| Fix Browser Autocomplete | Sửa lỗi gợi ý (trình duyệt) |
| Fix Chromium Browsers | Sửa lỗi trên Chromium |
| Step-by-Step Mode | Gửi từng phím |

### 4. SwiftUI Localization Approach
**Decision**: Leverage SwiftUI's automatic localization

**Implementation pattern**:
```swift
// Direct usage - SwiftUI auto-localizes
Text("Spell Checking")
Toggle("Auto-capitalize", isOn: $autoCapitalize)
Label("Input", systemImage: "keyboard")

// For help text with HelpLabel component
HelpLabel(
    String(localized: "Quick Telex"),
    help: String(localized: "cc → ch, gg → gi\nkk → kh, ngg → ngh\nqq → qu")
)

// Menu bar (AppKit) - explicit localization
let menuItem = NSMenuItem(
    title: String(localized: "Settings..."),
    action: #selector(openSettings),
    keyEquivalent: ","
)
```

### 5. Language Selection Strategy
**Decision**: Support both automatic (system) and manual language selection

**Options available to user**:
| Option | Value | Behavior |
|--------|-------|----------|
| Follow System | `"system"` | Use macOS system language (default) |
| English | `"en"` | Force English UI |
| Tiếng Việt | `"vi"` | Force Vietnamese UI |

**Implementation approach**:
```swift
// SettingsStore - new setting
enum AppLanguage: String, CaseIterable {
    case system = "system"  // Follow system language
    case english = "en"
    case vietnamese = "vi"

    var displayName: String {
        switch self {
        case .system: return String(localized: "Follow System")
        case .english: return "English"
        case .vietnamese: return "Tiếng Việt"
        }
    }
}

// On app launch (AppDelegate)
func applyLanguageSetting() {
    let language = SettingsStore.shared.appLanguage
    if language != .system {
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
    } else {
        UserDefaults.standard.removeObject(forKey: "AppleLanguages")
    }
}
```

**Why this approach**:
- `AppleLanguages` UserDefaults is Apple's standard mechanism
- Works consistently for both SwiftUI and AppKit components
- Requires app restart when changed (standard macOS behavior)
- Simple and reliable

**UI behavior**:
- Language picker added to Settings > Behavior section
- When user changes language, show restart prompt
- Restart can be automatic (relaunch app) or manual (user choice)

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Missing translations | Use English as fallback; Xcode shows warnings for missing keys |
| Inconsistent terminology | Reference OpenKey labels; document key terms in this proposal |
| String length issues | Test UI with Vietnamese strings (often longer than English) |
| Mixed SwiftUI/AppKit | Use `String(localized:)` consistently for AppKit components |

## Dependencies
- None (uses built-in Apple frameworks)

## Success Criteria
- [ ] All user-facing strings are localized
- [ ] Vietnamese UI displays correctly when system language is Vietnamese
- [ ] English UI displays correctly when system language is English
- [ ] No hardcoded strings in SwiftUI views
- [ ] UI layout handles both languages without truncation
- [ ] Language picker works correctly in Settings
- [ ] Manual language override persists and works after restart
- [ ] "Follow System" correctly follows macOS system language
