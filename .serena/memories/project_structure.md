# Project Structure

## Directory Layout

```
vn-ime/
├── Package.swift           # Swift Package Manager manifest
├── CLAUDE.md               # AI assistant instructions
├── README.md               # Project documentation
├── LICENSE                 # GPLv3 License
├── .swiftlint.yml          # SwiftLint configuration
├── .gitmodules             # Git submodules (OpenKey reference)
│
├── Sources/
│   └── VnIme/
│       ├── App/                    # Entry point, AppDelegate
│       │   ├── VnImeApp.swift      # @main SwiftUI App entry
│       │   ├── AppDelegate.swift   # NSApplicationDelegate
│       │   └── AppLifecycleManager.swift
│       │
│       ├── Core/                   # Vietnamese input engine
│       │   ├── Engine/             # Main processing logic
│       │   │   ├── VietnameseEngine.swift   # Engine protocol & implementation
│       │   │   ├── TypingBuffer.swift       # Word buffer management
│       │   │   ├── CharacterState.swift     # Character state encoding
│       │   │   ├── TypedCharacter.swift     # Typed character representation
│       │   │   └── VietnameseTable.swift    # Vietnamese character table
│       │   │
│       │   ├── InputMethods/       # Telex, Simple Telex handlers
│       │   ├── CharacterTables/    # Unicode encoding
│       │   └── Spelling/           # Spell checking rules
│       │
│       ├── EventHandling/          # CGEventTap, keyboard hook
│       ├── Features/               # Smart Switch, Quick Telex
│       ├── UI/                     # SwiftUI views, Menu bar
│       ├── Storage/                # UserDefaults, settings
│       ├── Utilities/              # Extensions, helpers
│       └── Resources/              # Assets, localization
│
├── Tests/
│   ├── VnImeTests/                 # Unit tests
│   │   ├── EngineTests.swift
│   │   ├── InputMethodTests.swift
│   │   ├── SpellCheckerTests.swift
│   │   └── ...
│   └── VnImeUITests/               # UI tests
│
├── OpenKey/                        # Reference implementation (git submodule)
│
└── openspec/                       # OpenSpec specifications
    ├── project.md                  # Project conventions
    ├── AGENTS.md                   # AI agent instructions
    ├── specs/                      # Current specifications
    │   ├── core-engine/
    │   ├── event-handling/
    │   ├── input-methods/
    │   ├── smart-switch/
    │   ├── spell-checking/
    │   ├── ui-settings/
    │   └── project-structure/
    └── changes/                    # Change proposals
        └── archive/                # Completed changes
```

## Key Files

### Entry Points
- `Sources/VnIme/App/VnImeApp.swift` - Main app entry (@main)
- `Sources/VnIme/App/AppDelegate.swift` - App lifecycle management

### Core Engine
- `Sources/VnIme/Core/Engine/VietnameseEngine.swift` - Main engine protocol and implementation
- `Sources/VnIme/Core/Engine/TypingBuffer.swift` - Buffer for current word
- `Sources/VnIme/Core/InputMethods/` - Input method implementations (Telex, etc.)

### Event Handling
- `Sources/VnIme/EventHandling/` - CGEventTap keyboard hook

### UI
- `Sources/VnIme/UI/` - SwiftUI settings views and menu bar

### Configuration
- `Package.swift` - SPM dependencies and targets
- `.swiftlint.yml` - Linting rules

## Module Architecture

```
VnIme (executable target)
├── @main VnImeApp
├── AppDelegate
│   └── Sets up event tap, menu bar, lifecycle
│
├── VietnameseEngine (protocol)
│   └── DefaultVietnameseEngine (implementation)
│       ├── InputMethod (protocol) → TelexInputMethod, SimpleTelexInputMethod
│       ├── CharacterTable (protocol) → UnicodeCharacterTable
│       ├── SpellChecker (protocol) → DefaultSpellChecker
│       └── TypingBuffer
│
└── UI Layer
    ├── SettingsView (SwiftUI)
    └── MenuBarView (AppKit)
```
