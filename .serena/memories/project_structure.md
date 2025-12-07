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
│       │   └── AppLifecycleManager.swift # Login item, dock visibility
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
│       ├── Localization/               # i18n support
│       │   └── Localized.swift         # LocalizationManager, L() function
│       │
│       └── Resources/                  # Assets, localization
│           ├── LotusKey-Info.plist
│           ├── Assets.xcassets/
│           │   └── AppIcon.appiconset/
│           ├── en.lproj/
│           │   └── Localizable.strings
│           └── vi.lproj/
│               └── Localizable.strings
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
├── LotusKey.app/                       # Built application bundle
│
└── openspec/                           # OpenSpec specifications
    ├── project.md                      # Project conventions
    ├── AGENTS.md                       # AI agent instructions
    ├── specs/                          # Current specifications
    │   ├── core-engine/spec.md
    │   ├── event-handling/spec.md
    │   ├── input-methods/spec.md
    │   ├── spell-checking/spec.md
    │   ├── smart-switch/spec.md
    │   ├── ui-settings/spec.md
    │   ├── project-structure/spec.md
    │   └── i18n/spec.md
    └── changes/                        # Change proposals
        └── archive/                    # Completed changes
```

## Key Files

### Entry Points
- `Sources/LotusKey/App/LotusKeyApp.swift` - Main app entry (@main)
- `Sources/LotusKey/App/AppDelegate.swift` - App lifecycle management
- `Sources/LotusKey/App/AppLifecycleManager.swift` - Login item, dock visibility

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

### Localization
- `Sources/LotusKey/Localization/Localized.swift` - LocalizationManager enum, L() helper function
- `Sources/LotusKey/Resources/en.lproj/Localizable.strings` - English strings
- `Sources/LotusKey/Resources/vi.lproj/Localizable.strings` - Vietnamese strings

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
├── Localization
│   └── LocalizationManager (enum) + L() helper
│
└── UI Layer
    ├── SettingsView (SwiftUI)
    └── MenuBarView (AppKit)
```

## OpenSpec Specifications

The project uses OpenSpec for managing requirements:
- `openspec/specs/core-engine/spec.md` - Vietnamese input processing engine
- `openspec/specs/event-handling/spec.md` - Keyboard event handling
- `openspec/specs/input-methods/spec.md` - Telex, Simple Telex methods
- `openspec/specs/spell-checking/spec.md` - Vietnamese spell checking
- `openspec/specs/smart-switch/spec.md` - Per-app language memory
- `openspec/specs/ui-settings/spec.md` - Settings UI
- `openspec/specs/project-structure/spec.md` - Project structure
- `openspec/specs/i18n/spec.md` - Internationalization
