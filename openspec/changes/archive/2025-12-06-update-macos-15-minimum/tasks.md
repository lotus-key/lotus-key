# Tasks: Update Minimum macOS Version to 15.0

## 1. Build Configuration

- [x] 1.1 Update `Package.swift` swift-tools-version from `5.9` to `6.2`
- [x] 1.2 Update platform target from `.macOS(.v13)` to `.macOS(.v15)`
- [x] 1.3 Remove `.enableExperimentalFeature("StrictConcurrency")` (default in Swift 6)
- [x] 1.4 Verify project builds successfully with `swift build`

## 2. Observable Migration

- [x] 2.1 Import Observation framework in `AccessibilityPermissionView.swift`
- [x] 2.2 Convert `AccessibilityPermissionViewModel` from `ObservableObject` to `@Observable`
- [x] 2.3 Remove `@Published` property wrapper from `isPermissionGranted`
- [x] 2.4 Update `AccessibilityPermissionView` to use plain property instead of `@ObservedObject`
- [x] 2.5 Migrate Timer to Task (Swift 6.2 structured concurrency pattern):
  - Replace `private var timer: Timer?` with `private var monitoringTask: Task<Void, Never>?`
  - Update `startMonitoring()` to use `Task { while !Task.isCancelled { ... } }`
  - Update `stopMonitoring()` to cancel task
- [x] 2.6 Update Preview macro to work with new Observable pattern

## 3. Remove Availability Checks

- [x] 3.1 Remove `#available(macOS 14.0, *)` check in `AppDelegate.openSettings()`
- [x] 3.2 Keep only the macOS 14+ code path (now baseline)

## 4. Documentation Updates

- [x] 4.1 Update `openspec/project.md` Tech Stack section:
  - Change "Minimum macOS: macOS 13.0 (Ventura)" to "Minimum macOS: macOS 15.0 (Sequoia)"
  - Update "Language: Swift 5.9+" to "Language: Swift 6.2+"
- [x] 4.2 Update any comments referencing minimum OS version

## 5. Verification

- [x] 5.1 Run `swift build` to verify compilation
- [x] 5.2 Run `swift test` to verify all tests pass
- [x] 5.3 Test app manually on macOS 15:
  - Launch app and verify menu bar icon appears
  - Test accessibility permission flow
  - Verify settings window opens and persists changes
  - Test Vietnamese input in various applications
- [x] 5.4 Verify no Swift 6 concurrency warnings/errors

## Dependencies

- Task 2 depends on Task 1 (need Swift 6 for @Observable)
- Task 3 can run in parallel with Task 2
- Task 4 can run in parallel with Tasks 2-3
- Task 5 depends on Tasks 1-4

## Notes

- No data migration needed - UserDefaults keys remain unchanged
- No changes to core engine or event handling logic
- Settings remain compatible via `@AppStorage` with same keys
