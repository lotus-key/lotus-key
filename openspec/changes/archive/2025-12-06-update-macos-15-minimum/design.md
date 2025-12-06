# Design: macOS 15 Minimum Version & Swift 6.2 Update

## Context

This change updates the minimum supported macOS version from 13.0 (Ventura) to 15.0 (Sequoia) and adopts Swift 6.2 with its new "Approachable Concurrency" features. This is a comprehensive modernization of the codebase.

### Stakeholders
- **End Users**: Must have macOS 15+ installed
- **Developers**: Must use Xcode 26+ with Swift 6.2 compiler

### Constraints
- Must maintain backward compatibility for user settings (UserDefaults)
- Must not break existing CGEventTap functionality
- Must follow Apple's recommended patterns for macOS 15

## Goals / Non-Goals

### Goals
- Update deployment target to macOS 15.0
- Adopt Swift 6.2 with Approachable Concurrency
- Migrate ObservableObject to @Observable macro
- Improve thread safety with Swift 6 strict concurrency
- Remove availability check boilerplate
- Update documentation to reflect new requirements

### Non-Goals
- Full rewrite of event handling system
- Adoption of InputMethodKit (IMKit) - out of scope
- UI redesign or new features
- Changes to input engine logic

## Decisions

### 1. Swift 6.2 Language Mode

**Decision**: Use Swift tools version 6.2 (latest: 6.2.1)

**Swift 6.2 Key Features Adopted**:

1. **Approachable Concurrency**
   - `nonisolated async` functions now run on caller's actor by default (no thread hop)
   - Use `@concurrent` when background execution is explicitly needed
   - Simpler mental model for async code

2. **Strict Concurrency (Default)**
   - Complete data-race safety at compile time
   - No need for `.enableExperimentalFeature("StrictConcurrency")`

**Rationale**:
- The codebase already uses `@MainActor` and `@unchecked Sendable` correctly
- Swift 6.2's Approachable Concurrency simplifies async patterns
- Strict concurrency is now default - no opt-in needed

### 2. @Observable Migration Strategy

**Decision**: Convert `AccessibilityPermissionViewModel` from `ObservableObject` to `@Observable`

**Migration Pattern**:
```swift
// Before (ObservableObject)
@MainActor
final class AccessibilityPermissionViewModel: ObservableObject {
    @Published var isPermissionGranted: Bool = false
}

struct AccessibilityPermissionView: View {
    @ObservedObject var viewModel: AccessibilityPermissionViewModel
}

// After (@Observable)
@Observable
@MainActor
final class AccessibilityPermissionViewModel {
    var isPermissionGranted: Bool = false  // No @Published needed
}

struct AccessibilityPermissionView: View {
    var viewModel: AccessibilityPermissionViewModel  // Plain property
}
```

**Why @Observable is Better**:
- No `@Published` boilerplate
- Fine-grained property tracking (better performance)
- Simpler view code (no `@ObservedObject` wrapper)

### 3. Concurrency Pattern Analysis

#### Current Patterns (Already Good ✅)

The codebase already follows Swift 6 best practices:

| Pattern | File | Status |
|---------|------|--------|
| `@MainActor` on UI classes | `AppDelegate.swift`, `AppLifecycleManager.swift` | ✅ Correct |
| `@unchecked Sendable` with locks | `SettingsStore.swift`, `SmartSwitch.swift` | ✅ Correct |
| Protocol `Sendable` requirements | All protocols | ✅ Correct |
| `Sendable` value types | `EngineResult`, `SpellCheckResult`, etc. | ✅ Correct |

#### Patterns That May Need Review

1. **`@unchecked Sendable` Classes**:
   - `KeyboardEventHandler`: Uses `@unchecked Sendable` with `fileprivate` vars
   - `TextInjector`: Uses `@unchecked Sendable`
   - `ApplicationDetector`: Uses `@unchecked Sendable` with `NSLock`
   - `SmartSwitch`: Uses `@unchecked Sendable` with `NSLock`

   **Recommendation**: Keep as-is. These use proper locking patterns.

2. **Timer in ViewModel**:
   ```swift
   // AccessibilityPermissionViewModel
   private var timer: Timer?
   ```
   **Recommendation**: Consider using `Task` with structured concurrency in Swift 6.2

### 4. Keep SettingsStore as Protocol-based

**Decision**: Do NOT migrate `SettingsStore` to `@Observable`

**Rationale**:
- Uses `SettingsStoring` protocol for dependency injection
- Already uses Combine's `PassthroughSubject` correctly
- Works correctly with `@AppStorage` in views
- Migration would add complexity without benefit

### 5. Keep @AppStorage in Views

**Decision**: Continue using `@AppStorage` directly in SwiftUI views

**Rationale**:
- Standard pattern for UserDefaults in SwiftUI
- Works seamlessly with SwiftUI's update mechanism
- Pattern remains valid in macOS 15 / Swift 6.2

### 6. Package.swift Updates

**Decision**: Update to Swift tools 6.2 and simplify settings

```swift
// Before
// swift-tools-version: 5.9
.macOS(.v13)
swiftSettings: [
    .enableExperimentalFeature("StrictConcurrency")
]

// After
// swift-tools-version: 6.2
.macOS(.v15)
// No swiftSettings needed - Swift 6 strict concurrency is default
```

### 7. Timer to Task Migration (Required)

**Current Code** (AccessibilityPermissionViewModel) - Old Pattern:
```swift
private var timer: Timer?

func startMonitoring() {
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
        Task { @MainActor [weak self] in
            self?.checkPermission()
        }
    }
}
```

**Problems with Old Pattern**:
- Mixes Foundation Timer with Swift Concurrency
- Requires `weak self` dance
- Timer closure → Task dispatch is indirect
- Not idiomatic Swift 6.2

**Swift 6.2 Pattern** (Required):
```swift
private var monitoringTask: Task<Void, Never>?

func startMonitoring() {
    monitoringTask = Task {
        while !Task.isCancelled {
            checkPermission()
            try? await Task.sleep(for: .seconds(1))
        }
    }
}

func stopMonitoring() {
    monitoringTask?.cancel()
    monitoringTask = nil
}
```

**Why This is Required (Not Optional)**:
- Pure Swift structured concurrency - no Foundation Timer dependency
- Automatic cancellation support via `Task.isCancelled`
- No `weak self` needed - Task captures self correctly
- `@MainActor` class means Task body runs on MainActor automatically
- Idiomatic Swift 6.2 pattern

## Code Changes Summary

### Files Requiring Changes

| File | Change Type | Description |
|------|-------------|-------------|
| `Package.swift` | **MODIFY** | Update tools version to 6.2, platform to .v15, remove swiftSettings |
| `AccessibilityPermissionView.swift` | **MODIFY** | Migrate to @Observable, migrate Timer to Task |
| `AppDelegate.swift` | **MODIFY** | Remove `#available(macOS 14.0, *)` check |
| `openspec/project.md` | **MODIFY** | Update documented requirements |

### Files Already Swift 6.2 Compatible

| File | Status | Notes |
|------|--------|-------|
| `VietnameseEngine.swift` | ✅ Ready | Uses `Sendable` correctly |
| `TypingBuffer.swift` | ✅ Ready | `Sendable` struct |
| `TextInjector.swift` | ✅ Ready | `@unchecked Sendable` with proper isolation |
| `KeyboardEventHandler.swift` | ✅ Ready | `@unchecked Sendable` with proper isolation |
| `SettingsStore.swift` | ✅ Ready | `@unchecked Sendable` with NSLock |
| `SmartSwitch.swift` | ✅ Ready | `@unchecked Sendable` with NSLock |
| `ApplicationDetector.swift` | ✅ Ready | `@unchecked Sendable` with NSLock |
| `SpellChecker.swift` | ✅ Ready | All types are `Sendable` |
| All InputMethod files | ✅ Ready | `Sendable` protocols and structs |

## Risks / Trade-offs

### Risk: User Base Reduction
- **Impact**: Users on macOS 13-14 cannot use the app
- **Mitigation**: macOS 15 has high adoption rate; users can use older app versions
- **Decision**: Accept trade-off for cleaner codebase

### Risk: Swift 6.2 Compilation Errors
- **Impact**: Stricter concurrency checking may reveal hidden issues
- **Mitigation**: Codebase already uses proper actor isolation; test thoroughly
- **Likelihood**: Low - code follows modern patterns

### Risk: CGEventTap Changes in macOS 15
- **Impact**: Some CGEventTap behaviors changed in macOS 15
- **Mitigation**:
  - App doesn't use Option-key shortcuts (main breaking change)
  - Test event handling thoroughly on macOS 15
- **Likelihood**: Low - current implementation uses standard patterns

## Migration Plan

### Phase 1: Build Configuration
1. Update `Package.swift` with new deployment target and Swift version
2. Verify project builds with Xcode 26

### Phase 2: Code Updates
1. Migrate `AccessibilityPermissionViewModel` to `@Observable`
2. Update `AccessibilityPermissionView` to use plain property
3. Migrate Timer to Task in ViewModel (Swift 6.2 pattern)
4. Remove `#available(macOS 14.0, *)` check in `AppDelegate`

### Phase 3: Documentation
1. Update `openspec/project.md` with new requirements

### Phase 4: Verification
1. Run `swift build` to verify compilation
2. Run `swift test` to verify all tests pass
3. Test app manually on macOS 15

### Rollback Plan
- Revert Package.swift changes
- Revert Observable migration
- No data migration needed

## Open Questions

None - the scope is well-defined and the codebase is already well-prepared for Swift 6.2.

## References

- [Swift 6.2 Released - Official Announcement](https://swift.org/blog/swift-6.2-released/)
- [Approachable Concurrency Vision](https://github.com/swiftlang/swift-evolution/blob/main/visions/approachable-concurrency.md)
- [Migrating from ObservableObject to Observable](https://developer.apple.com/documentation/SwiftUI/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro)
- [SE-0461: Async Function Isolation](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0461-async-function-isolation.md)
