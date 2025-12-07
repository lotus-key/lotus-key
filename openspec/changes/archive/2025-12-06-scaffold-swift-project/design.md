# Design: Swift Project Structure

## Context

LotusKey is a macOS Vietnamese input method application that requires:
- System-wide keyboard event capture (CGEventTap) - requires Accessibility permissions
- Background operation with menu bar UI
- SwiftUI for settings, AppKit for system integration
- No sandboxing (accessibility requirement)
- No external dependencies (security/maintenance)

## Goals / Non-Goals

**Goals:**
- Establish Swift Package Manager project structure following 2024-2025 best practices
- Match architecture defined in `openspec/project.md`
- Enable incremental development with clear module boundaries
- Support 80%+ test coverage target for core engine

**Non-Goals:**
- Implement actual Vietnamese input logic (separate changes)
- Create Xcode project file (SPM handles this)
- Add external dependencies

## Decisions

### Decision: Use Swift Package Manager exclusively

**Rationale:** Modern Swift development standard. Xcode 15+ fully supports SPM for macOS apps. Eliminates `.xcodeproj` file maintenance.

**Alternatives considered:**
- Xcode project only: Harder to version control, more merge conflicts
- CocoaPods/Carthage: Unnecessary complexity, no external deps needed

### Decision: Executable target with strict concurrency

**Rationale:** Swift 5.9+ with strict concurrency checking catches threading issues at compile time. Critical for event handling code that must be thread-safe.

```swift
swiftSettings: [
    .enableExperimentalFeature("StrictConcurrency")
]
```

### Decision: Feature-based directory organization

**Rationale:** Matches `project.md` architecture. Groups related code by domain (Core, EventHandling, Features, UI) rather than technical layer.

```
Sources/LotusKey/
├── App/                    # Entry point
├── Core/                   # Domain logic
│   ├── Engine/
│   ├── InputMethods/
│   ├── CharacterTables/
│   └── Spelling/
├── EventHandling/          # System integration
├── Features/               # Feature modules
├── UI/                     # Presentation
├── Storage/                # Persistence
└── Utilities/              # Shared helpers
```

### Decision: Protocol-first stubs

**Rationale:** Enables dependency injection for testing. Matches `project.md` design patterns (Protocol-Oriented, Dependency Injection). Stub files define interfaces before implementation.

### Decision: Separate test targets for unit and UI tests

**Rationale:**
- Unit tests: Fast, isolated, test core logic
- UI tests: Slower, integration-focused, test user flows
- Allows running unit tests frequently during development

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| SPM limitations with Info.plist | Use `Resources/Info.plist` processed by SPM; supplement with Xcode settings if needed |
| Menu bar app requires AppKit | Hybrid SwiftUI+AppKit approach; use `NSApplicationDelegateAdaptor` |
| Accessibility API requires entitlements | Document in README; provide setup instructions |

## Open Questions

- None; scaffold is straightforward following established patterns
