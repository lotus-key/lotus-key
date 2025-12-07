# Tasks: Add i18n Support

## Overview

Implementation tasks for adding English/Vietnamese localization to LotusKey.

---

## Phase 1: Setup String Catalog

### Task 1.1: Create String Catalog File

- [x] Create `Sources/LotusKey/Resources/Localizable.xcstrings`
- [x] Add English (en) as development language
- [x] Add Vietnamese (vi) as secondary language
- [x] Remove legacy `Localizable.strings` file

### Task 1.2: Add Language Selection Infrastructure

- [x] Add `AppLanguage` enum to `SettingsStore.swift`
- [x] Add `appLanguage` setting with key `LotusKeyAppLanguage`
- [x] Add `applyLanguageSetting()` function in `AppDelegate.swift`
- [x] Call `applyLanguageSetting()` early in app launch (before UI loads)

---

## Phase 2: Settings View Localization

### Task 2.1: Localize Tab Names

- [x] "General" → "Chung"
- [x] "About" → "Giới thiệu"

### Task 2.2: Localize Section Headers

- [x] "Input" → "Kiểu gõ"
- [x] "Spelling" → "Chính tả"
- [x] "Behavior" → "Hệ thống"
- [x] "Compatibility" → "Tương thích"

### Task 2.3: Localize Input Section

- [x] "Input Method" picker label → "Kiểu gõ"
- [x] "Quick Telex" toggle → "Gõ nhanh"
- [x] Quick Telex help text (keep same, universal)
- [x] "Auto-capitalize" → "Viết hoa chữ cái đầu câu"

### Task 2.4: Localize Spelling Section

- [x] "Spell Checking" → "Kiểm tra chính tả"
- [x] "Restore Invalid Words" → "Tự khôi phục phím với từ sai"
- [x] Help text: "Reverts text if invalid..." → "Khôi phục văn bản nếu từ sai..."

### Task 2.5: Localize Behavior Section

- [x] "Smart Language Switch" → "Chuyển chế độ thông minh"
- [x] Help text: "Remembers preference..." → "Ghi nhớ ngôn ngữ theo ứng dụng"
- [x] "Launch at Login" → "Khởi động cùng macOS"
- [x] "Show in Dock" → "Hiện biểu tượng trên thanh Dock"

### Task 2.6: Localize Compatibility Section

- [x] "Fix Browser Autocomplete" → "Sửa lỗi gợi ý (trình duyệt)"
- [x] "Fix Chromium Browsers" → "Sửa lỗi trên Chromium"
- [x] "Step-by-Step Mode" → "Gửi từng phím"
- [x] Help texts for each option

### Task 2.7: Localize About Tab

- [x] App name "LotusKey" (keep unchanged)
- [x] "Version %@" → "Phiên bản %@"
- [x] "Vietnamese Input Method for macOS" → "Bộ gõ Tiếng Việt dành cho macOS"
- [x] "GitHub" link label (keep unchanged)
- [x] Copyright and license text

### Task 2.8: Add Language Picker UI

- [x] Add language picker to Settings > Behavior section
- [x] Picker options: "Follow System", "English", "Tiếng Việt"
- [x] "Follow System" label → "Theo hệ thống" (vi)
- [x] "Language" picker label → "Ngôn ngữ" (vi)
- [x] Show restart alert when language is changed
- [x] Implement "Restart Now" and "Later" buttons
- [x] Add restart functionality using `NSApp.terminate` + relaunch

---

## Phase 3: Menu Bar Localization

### Task 3.1: Localize Menu Items

- [x] Language toggle: "Vietnamese" / "English" → "Tiếng Việt" / "Tiếng Anh"
- [x] "Settings..." → "Bảng điều khiển..."
- [x] "Quit LotusKey" → "Thoát"

---

## Phase 4: Accessibility View Localization

### Task 4.1: Localize Permission UI

- [x] Permission description text
- [x] Button labels
- [x] Error messages

---

## Phase 5: Vietnamese Translations Summary

### Complete Translation Table

| English Key | Vietnamese Translation |
|-------------|------------------------|
| General | Chung |
| About | Giới thiệu |
| Input | Kiểu gõ |
| Spelling | Chính tả |
| Behavior | Hệ thống |
| Compatibility | Tương thích |
| Input Method | Kiểu gõ |
| Quick Telex | Gõ nhanh |
| Auto-capitalize | Viết hoa chữ cái đầu câu |
| Spell Checking | Kiểm tra chính tả |
| Restore Invalid Words | Tự khôi phục phím với từ sai |
| Smart Language Switch | Chuyển chế độ thông minh |
| Launch at Login | Khởi động cùng macOS |
| Show in Dock | Hiện biểu tượng trên thanh Dock |
| Fix Browser Autocomplete | Sửa lỗi gợi ý (trình duyệt) |
| Fix Chromium Browsers | Sửa lỗi trên Chromium |
| Step-by-Step Mode | Gửi từng phím |
| Vietnamese | Tiếng Việt |
| English | Tiếng Anh |
| Settings... | Bảng điều khiển... |
| Quit LotusKey | Thoát |
| Version %@ | Phiên bản %@ |
| Vietnamese Input Method for macOS | Bộ gõ Tiếng Việt dành cho macOS |
| Language | Ngôn ngữ |
| Follow System | Theo hệ thống |
| Restart Required | Cần khởi động lại |
| Restart Now | Khởi động lại ngay |
| Later | Để sau |
| Language change requires restart | Thay đổi ngôn ngữ cần khởi động lại ứng dụng |

---

## Phase 6: Testing & Validation

### Task 6.1: Test English Locale

- [x] Verify all strings display in English
- [x] Check for truncation or layout issues
- [x] Verify help popovers work correctly

### Task 6.2: Test Vietnamese Locale

- [x] Set system language to Vietnamese
- [x] Verify all strings display in Vietnamese
- [x] Check for truncation (Vietnamese strings may be longer)
- [x] Verify special characters render correctly (ă, ơ, ư, etc.)

### Task 6.3: Test Language Selection

- [x] Test "Follow System" option (default)
- [x] Test manual English selection with Vietnamese system
- [x] Test manual Vietnamese selection with English system
- [x] Verify restart prompt appears when changing language
- [x] Verify "Restart Now" relaunches app correctly
- [x] Verify "Later" saves setting for next launch

### Task 6.4: Build Verification

- [x] Run `swift build` successfully
- [x] Run `swiftlint lint` with no errors
- [x] Run existing tests

---

## Dependencies

- Task 2.x depends on Task 1.x (string catalog must exist first)
- Task 6.x depends on all previous tasks

## Parallelizable Work

- Tasks 2.1 through 2.7 can be done in parallel after Task 1.1
- Tasks 3.1 and 4.1 can be done in parallel with Phase 2
- Tasks 6.1 and 6.2 can be done in parallel
