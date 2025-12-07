# Project Structure

## Directory Layout

```
lotus-key/
├── Package.swift           # Swift Package Manager manifest
├── CLAUDE.md               # AI assistant instructions
├── README.md               # Project documentation
├── LICENSE                 # GPLv3 License
├── .swiftlint.yml          # SwiftLint configuration
├── .gitmodules             # Git submodules (OpenKey reference)
│
├── Sources/
│   └── LotusKey/
│       ├── App/                        # Entry point
│       │   ├── LotusKeyApp.swift       # @main SwiftUI App entry
│       │   ├── AppDelegate.swift       # NSApplicationDelegate
│       │   └── AppLifecycleManager.swift
│       │
│       ├── Core/                       # Vietnamese input engine
│       │   ├── Engine/                 # Main processing logic
│       │   │   ├── VietnameseEngine.swift   # Engine protocol & impl
│       │   │   ├── TypingBuffer.swift       # Word buffer management
│       │   │   ├── CharacterState.swift     # Character state encoding
│       │   │   ├── TypedCharacter.swift     # Typed character repr
│       │   │   └── VietnameseTable.swift    # Vietnamese char table
│       │   │
│       │   ├── InputMethods/           # Telex, Simple Telex handlers
│       │   │   ├── InputMethod.swift        # InputMethod protocol
│       │   │   ├── InputMethodRegistry.swift
│       │   │   ├── TelexInputMethod.swift
│       │   │   └── SimpleTelexInputMethod.swift
│       │   │
│       │   ├── CharacterTables/        # Unicode encoding
│       │   │   └── CharacterTable.swift
│       │   │
│       │   └── Spelling/               # Spell checking rules
│       │       └── SpellChecker.swift
│       │
│       ├── EventHandling/              # CGEventTap, keyboard hook
│       │   ├── KeyboardEventHandler.swift   # Main event tap handler
│       │   ├── TextInjector.swift           # Text injection via CGEvent
│       │   ├── KeyboardLayoutConverter.swift # Layout conversion
│       │   ├── InputSourceDetector.swift    # IME detection (CJK bypass)
│       │   ├── HotkeyDetector.swift         # Hotkey detection
│       │   └── ApplicationDetector.swift    # Per-app detection
│       │
│       ├── Features/                   # Feature modules
│       │   ├── SmartSwitch.swift       # Per-app language memory
│       │   └── QuickTelex.swift        # Quick consonant shortcuts
│       │
│       ├── UI/                         # SwiftUI views
│       │   ├── SettingsView.swift      # Settings window
│       │   └── AccessibilityPermissionView.swift
│       │
│       ├── Storage/                    # Persistence
│       │   └── SettingsStore.swift     # UserDefaults wrapper
│       │
│       ├── Utilities/                  # Extensions, helpers
│       │   └── Extensions.swift
│       │
│       └── Resources/                  # Assets, localization
│           ├── LotusKey-Info.plist
│           ├── Localizable.strings
│           └── Assets.xcassets/
│
├── Tests/
│   ├── LotusKeyTests/                  # Unit tests
│   │   ├── EngineTests.swift
│   │   ├── InputMethodTests.swift
│   │   ├── SpellCheckerTests.swift
│   │   ├── TypingBufferTests.swift
│   │   ├── CharacterStateTests.swift
│   │   ├── VietnameseTableTests.swift
│   │   ├── StorageTests.swift
│   │   ├── KeyboardEventHandlerTests.swift
│   │   ├── TextInjectorTests.swift
│   │   ├── HotkeyDetectorTests.swift
│   │   ├── ApplicationDetectorTests.swift
│   │   └── AppLifecycleManagerTests.swift
│   │
│   └── LotusKeyUITests/                # UI tests
│       └── SettingsUITests.swift
│
├── OpenKey/                            # Reference implementation (git submodule)
│
└── openspec/                           # OpenSpec specifications
    ├── project.md                      # Project conventions
    ├── AGENTS.md                       # AI agent instructions
    ├── specs/                          # Current specifications
    └── changes/                        # Change proposals
        └── archive/                    # Completed changes
```

## Key Files

### Entry Points
- `Sources/LotusKey/App/LotusKeyApp.swift` - Main app entry (@main)
- `Sources/LotusKey/App/AppDelegate.swift` - App lifecycle management

### Core Engine
- `Sources/LotusKey/Core/Engine/VietnameseEngine.swift` - Main engine protocol and implementation
- `Sources/LotusKey/Core/Engine/TypingBuffer.swift` - Buffer for current word
- `Sources/LotusKey/Core/Engine/CharacterState.swift` - Character state encoding (bit flags)
- `Sources/LotusKey/Core/Engine/TypedCharacter.swift` - Typed character representation
- `Sources/LotusKey/Core/Engine/VietnameseTable.swift` - Vietnamese character lookup table
- `Sources/LotusKey/Core/InputMethods/InputMethod.swift` - Input method protocol
- `Sources/LotusKey/Core/InputMethods/TelexInputMethod.swift` - Telex implementation
- `Sources/LotusKey/Core/InputMethods/SimpleTelexInputMethod.swift` - Simple Telex
- `Sources/LotusKey/Core/Spelling/SpellChecker.swift` - Spell checking

### Event Handling
- `Sources/LotusKey/EventHandling/KeyboardEventHandler.swift` - Main CGEventTap handler
- `Sources/LotusKey/EventHandling/TextInjector.swift` - Text injection via CGEvent
- `Sources/LotusKey/EventHandling/KeyboardLayoutConverter.swift` - Non-QWERTY support
- `Sources/LotusKey/EventHandling/InputSourceDetector.swift` - IME detection (CJK bypass)
- `Sources/LotusKey/EventHandling/HotkeyDetector.swift` - Hotkey detection
- `Sources/LotusKey/EventHandling/ApplicationDetector.swift` - Per-app detection

### Features
- `Sources/LotusKey/Features/SmartSwitch.swift` - Per-app language memory
- `Sources/LotusKey/Features/QuickTelex.swift` - Quick consonant shortcuts (cc=ch, etc.)

### UI
- `Sources/LotusKey/UI/SettingsView.swift` - Settings window (SwiftUI)
- `Sources/LotusKey/UI/AccessibilityPermissionView.swift` - Permission prompt

### Storage
- `Sources/LotusKey/Storage/SettingsStore.swift` - UserDefaults wrapper

### Configuration
- `Package.swift` - SPM dependencies and targets
- `.swiftlint.yml` - Linting rules

## Module Architecture

```
LotusKey (executable target)
├── @main LotusKeyApp
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
