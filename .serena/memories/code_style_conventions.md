# Code Style and Conventions

## Naming Conventions

- **Variables/functions**: camelCase (`processKey`, `currentText`)
- **Types (classes, structs, enums, protocols)**: PascalCase (`VietnameseEngine`, `EngineResult`)
- **Constants**: camelCase (Swift convention)
- **File names**: PascalCase matching type name (`VietnameseEngine.swift`)

## Swift Best Practices

### Prefer `let` over `var`
```swift
// Good
let result = engine.processKey(...)

// Only use var when mutation is needed
var buffer = TypingBuffer()
```

### Use Strong Typing
```swift
// Avoid Any
// Bad
func process(_ value: Any) -> Any

// Good
func process(_ value: Character) -> EngineResult
```

### Avoid Force Unwrapping
```swift
// Bad
let value = optionalValue!

// Good
if let value = optionalValue {
    // use value
}
// OR
guard let value = optionalValue else { return }
```

### Prefer Value Types
```swift
// Prefer structs and enums when suitable
struct TypingBuffer { ... }
enum EngineResult { ... }

// Use class only when reference semantics needed
final class DefaultVietnameseEngine { ... }
```

## Code Organization

### Use MARK Comments
```swift
// MARK: - Properties
private var buffer: TypingBuffer

// MARK: - Initialization
public init() { ... }

// MARK: - Main Processing
public func processKey(...) { ... }
```

### Document Public APIs with DocC
```swift
/// Result of processing a keyboard event
public enum EngineResult: Sendable, Equatable {
    /// No action needed, pass through the original key
    case passThrough
    /// Suppress the key, engine handled it internally
    case suppress
    /// Replace with new characters (backspace count, new string)
    case replace(backspaceCount: Int, replacement: String)
}

/// Process a key press event
/// - Parameters:
///   - keyCode: The virtual key code
///   - character: The character representation of the key
///   - modifiers: Modifier flags (shift, control, etc.)
/// - Returns: The result indicating how to handle the event
func processKey(keyCode: UInt16, character: Character?, modifiers: UInt64) -> EngineResult
```

## SwiftLint Rules

Key configurations from `.swiftlint.yml`:

### Identifier Names
- Min length: 2 (warning), 1 (error)
- Max length: 50 (warning), 60 (error)
- Allowed short names: `id`, `i`, `x`, `y`

### File/Type Limits
- File length: 500 (warning), 1000 (error)
- Type body length: 300 (warning), 500 (error)
- Function body length: 50 (warning), 100 (error)
- Function parameters: 6 (warning), 8 (error)

### Complexity
- Cyclomatic complexity: 15 (warning), 25 (error)
- Nesting type level: 2 (warning), 3 (error)
- Nesting function level: 3 (warning), 5 (error)

### Formatting
- Trailing comma: mandatory
- Vertical whitespace: max 2 empty lines

## Architecture Patterns

### Protocol-Oriented Design
```swift
public protocol VietnameseEngine: Sendable {
    func processKey(keyCode: UInt16, character: Character?, modifiers: UInt64) -> EngineResult
    func reset()
    var inputMethod: any InputMethod { get }
}
```

### Dependency Injection
```swift
public init(
    inputMethod: any InputMethod = TelexInputMethod(),
    characterTable: any CharacterTable = UnicodeCharacterTable()
) {
    self._inputMethod = inputMethod
    self._characterTable = characterTable
}
```

### Use Swift Concurrency
- Mark types as `Sendable` when appropriate
- Use `async/await` for asynchronous operations
- `@unchecked Sendable` only when thread-safety is manually ensured

## Testing Conventions

### Test Structure
```swift
final class EngineTests: XCTestCase {
    var engine: DefaultVietnameseEngine!

    override func setUp() {
        super.setUp()
        engine = DefaultVietnameseEngine()
    }

    override func tearDown() {
        engine = nil
        super.tearDown()
    }

    // MARK: - Basic Tests
    func testEngineInitialization() { ... }
}
```

### Test Naming
- Use descriptive names: `testBackspaceEmptyBuffer`, `testPunctuationIsWordBreak`
- Group related tests with MARK comments

### Coverage Requirements
- Core logic components: 100% line coverage required
- Logic components include: CharacterState, TypedCharacter, TypingBuffer, VietnameseEngine, VietnameseTable, CharacterTable, InputMethod, InputMethodRegistry, TelexInputMethod, SimpleTelexInputMethod, SpellChecker, QuickTelex
- Non-logic (UI, EventHandling, Storage, App) excluded from coverage requirement

## Localization Conventions

### String Localization
```swift
// SwiftUI - automatic localization via LocalizedStringKey
Text("Settings")  // Automatically localized

// AppKit / manual
let text = L("Settings")  // Uses LocalizationManager

// With format
String(format: L("Version %@"), version)
```

### Localizable.strings Format
```
/* Comment describing the string */
"key" = "value";
```

### Language Support
- English (en) - Default language
- Vietnamese (vi) - Primary user language
- "Follow System" option available
