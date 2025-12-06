# project-structure Specification

## Purpose
Defines the Swift Package Manager project structure, directory organization, resource management, and build configuration for the VnIme macOS application.
## Requirements
### Requirement: Swift Package Manager Configuration

The project SHALL use Swift Package Manager as the build system with a `Package.swift` file at the repository root.

#### Scenario: Valid package configuration

- **WHEN** the package is initialized
- **THEN** it SHALL target Swift 5.9+ and macOS 13.0+
- **AND** it SHALL define an executable target named `VnIme`
- **AND** it SHALL define test targets `VnImeTests` and `VnImeUITests`
- **AND** it SHALL enable strict concurrency checking

#### Scenario: No external dependencies

- **WHEN** the package dependencies are evaluated
- **THEN** the package SHALL have zero external dependencies
- **AND** it SHALL only use Apple system frameworks (Carbon, AppKit, SwiftUI, Combine)

### Requirement: Source Directory Organization

The project SHALL organize source code under `Sources/VnIme/` following a feature-based directory structure.

#### Scenario: Core directories exist

- **WHEN** the project is scaffolded
- **THEN** the following directories SHALL exist:
  - `Sources/VnIme/App/`
  - `Sources/VnIme/Core/Engine/`
  - `Sources/VnIme/Core/InputMethods/`
  - `Sources/VnIme/Core/CharacterTables/`
  - `Sources/VnIme/Core/Spelling/`
  - `Sources/VnIme/EventHandling/`
  - `Sources/VnIme/Features/`
  - `Sources/VnIme/UI/`
  - `Sources/VnIme/Storage/`
  - `Sources/VnIme/Utilities/`

#### Scenario: Entry point structure

- **WHEN** the App directory is scaffolded
- **THEN** it SHALL contain `VnImeApp.swift` as the SwiftUI app entry point
- **AND** it SHALL contain `AppDelegate.swift` for AppKit integration

### Requirement: Test Directory Organization

The project SHALL organize tests under `Tests/` with separate targets for unit and UI tests.

#### Scenario: Test directories exist

- **WHEN** the project is scaffolded
- **THEN** `Tests/VnImeTests/` SHALL exist for unit tests
- **AND** `Tests/VnImeUITests/` SHALL exist for UI tests

#### Scenario: Test target dependencies

- **WHEN** test targets are defined
- **THEN** `VnImeTests` SHALL depend on `VnIme` target
- **AND** `VnImeUITests` SHALL depend on `VnIme` target

### Requirement: Resource Management

The project SHALL include resources for assets, localization, and configuration.

#### Scenario: Asset catalog exists

- **WHEN** the project is scaffolded
- **THEN** `Sources/VnIme/Resources/Assets.xcassets/` SHALL exist
- **AND** it SHALL contain an AppIcon.appiconset placeholder

#### Scenario: Localization files exist

- **WHEN** the project is scaffolded
- **THEN** `Sources/VnIme/Resources/Localizable.strings` SHALL exist
- **AND** it SHALL support Vietnamese (primary) and English languages

#### Scenario: Info.plist exists

- **WHEN** the project is scaffolded
- **THEN** `Sources/VnIme/Resources/Info.plist` SHALL exist
- **AND** it SHALL include `NSAccessibilityUsageDescription` key for accessibility permissions

### Requirement: Protocol-First Design

Core components SHALL define protocols before implementations to enable dependency injection and testing.

#### Scenario: Engine protocol defined

- **WHEN** the Core/Engine directory is scaffolded
- **THEN** it SHALL contain a `VietnameseEngine` protocol defining the input processing interface

#### Scenario: Input method protocol defined

- **WHEN** the Core/InputMethods directory is scaffolded
- **THEN** it SHALL contain an `InputMethod` protocol
- **AND** it SHALL contain stub implementation for `TelexInputMethod`

#### Scenario: Character table protocol defined

- **WHEN** the Core/CharacterTables directory is scaffolded
- **THEN** it SHALL contain a `CharacterTable` protocol for encoding conversions

#### Scenario: Spell checker protocol defined

- **WHEN** the Core/Spelling directory is scaffolded
- **THEN** it SHALL contain a `SpellChecker` protocol for Vietnamese word validation

### Requirement: Build Verification

The scaffolded project SHALL compile and run tests successfully.

#### Scenario: Project compiles

- **WHEN** `swift build` is executed
- **THEN** the build SHALL succeed without errors

#### Scenario: Tests run

- **WHEN** `swift test` is executed
- **THEN** all test targets SHALL run without failures

