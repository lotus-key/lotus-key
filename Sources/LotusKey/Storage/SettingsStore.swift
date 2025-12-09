import Combine
import Foundation

/// Keys for UserDefaults storage
public enum SettingsKey: String {
    case appLanguage = "LotusKeyAppLanguage"
    case autoCapitalize = "LotusKeyAutoCapitalize"
    case fixBrowserAutocomplete = "LotusKeyFixBrowserAutocomplete"
    case fixChromiumBrowser = "LotusKeyFixChromiumBrowser"
    case inputMethod = "LotusKeyInputMethod"
    case launchAtLogin = "LotusKeyLaunchAtLogin"
    case quickTelexEnabled = "LotusKeyQuickTelexEnabled"
    case restoreIfWrongSpelling = "LotusKeyRestoreIfWrongSpelling"
    case sendKeyStepByStep = "LotusKeySendKeyStepByStep"
    case showDockIcon = "LotusKeyShowDockIcon"
    case smartSwitchEnabled = "LotusKeySmartSwitchEnabled"
    case spellCheckEnabled = "LotusKeySpellCheckEnabled"
    case switchLanguageHotkey = "LotusKeySwitchLanguageHotkey"
}

/// App language selection for i18n
public enum AppLanguage: String, CaseIterable {
    case english = "en"
    case system
    case vietnamese = "vi"

    public var displayName: String {
        switch self {
        case .english: "English"
        case .system: L("Follow System")
        case .vietnamese: "Tiếng Việt"
        }
    }
}

/// Protocol for settings storage
public protocol SettingsStoring: AnyObject, Sendable {
    // Input settings
    var inputMethod: String { get set }
    var spellCheckEnabled: Bool { get set }
    var quickTelexEnabled: Bool { get set }
    var autoCapitalize: Bool { get set }
    var restoreIfWrongSpelling: Bool { get set }

    // App behavior
    var smartSwitchEnabled: Bool { get set }
    var launchAtLogin: Bool { get set }
    var showDockIcon: Bool { get set }

    // Advanced settings
    var fixBrowserAutocomplete: Bool { get set }
    var fixChromiumBrowser: Bool { get set }
    var sendKeyStepByStep: Bool { get set }

    // i18n
    var appLanguage: AppLanguage { get set }

    // Shortcut (bitfield format: bits 0-7 keyCode, 8 ctrl, 9 opt, 10 cmd, 11 shift, 15 beep)
    var switchLanguageHotkey: UInt32 { get set }

    // Publisher for settings changes
    var settingsChanged: AnyPublisher<SettingsKey, Never> { get }

    // Reset to defaults
    func resetToDefaults()
}

/// Default settings storage using UserDefaults
public final class SettingsStore: SettingsStoring, @unchecked Sendable {
    private let defaults: UserDefaults
    private let settingsChangedSubject = PassthroughSubject<SettingsKey, Never>()
    private let lock = NSLock()

    public var settingsChanged: AnyPublisher<SettingsKey, Never> {
        settingsChangedSubject.eraseToAnyPublisher()
    }

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        registerDefaults()
    }

    private func registerDefaults() {
        defaults.register(defaults: [
            SettingsKey.inputMethod.rawValue: "Telex",
            SettingsKey.spellCheckEnabled.rawValue: true,
            SettingsKey.smartSwitchEnabled.rawValue: true,
            SettingsKey.quickTelexEnabled.rawValue: true,
            SettingsKey.launchAtLogin.rawValue: false,
            SettingsKey.showDockIcon.rawValue: false,
            SettingsKey.autoCapitalize.rawValue: true,
            SettingsKey.restoreIfWrongSpelling.rawValue: true,
            // Advanced settings
            SettingsKey.fixBrowserAutocomplete.rawValue: true,
            SettingsKey.fixChromiumBrowser.rawValue: true,
            SettingsKey.sendKeyStepByStep.rawValue: false,
            // i18n
            SettingsKey.appLanguage.rawValue: AppLanguage.system.rawValue,
            // Shortcut: Ctrl+Space with beep (0x31 | 0x100 | 0x8000)
            SettingsKey.switchLanguageHotkey.rawValue: 0x8131,
        ])
    }

    // MARK: - Input Settings

    public var inputMethod: String {
        get {
            lock.lock()
            defer { lock.unlock() }
            return defaults.string(forKey: SettingsKey.inputMethod.rawValue) ?? "Telex"
        }
        set {
            lock.lock()
            defaults.set(newValue, forKey: SettingsKey.inputMethod.rawValue)
            lock.unlock()
            settingsChangedSubject.send(.inputMethod)
        }
    }

    public var spellCheckEnabled: Bool {
        get {
            lock.lock()
            defer { lock.unlock() }
            return defaults.bool(forKey: SettingsKey.spellCheckEnabled.rawValue)
        }
        set {
            lock.lock()
            defaults.set(newValue, forKey: SettingsKey.spellCheckEnabled.rawValue)
            lock.unlock()
            settingsChangedSubject.send(.spellCheckEnabled)
        }
    }

    public var quickTelexEnabled: Bool {
        get {
            lock.lock()
            defer { lock.unlock() }
            return defaults.bool(forKey: SettingsKey.quickTelexEnabled.rawValue)
        }
        set {
            lock.lock()
            defaults.set(newValue, forKey: SettingsKey.quickTelexEnabled.rawValue)
            lock.unlock()
            settingsChangedSubject.send(.quickTelexEnabled)
        }
    }

    public var autoCapitalize: Bool {
        get {
            lock.lock()
            defer { lock.unlock() }
            return defaults.bool(forKey: SettingsKey.autoCapitalize.rawValue)
        }
        set {
            lock.lock()
            defaults.set(newValue, forKey: SettingsKey.autoCapitalize.rawValue)
            lock.unlock()
            settingsChangedSubject.send(.autoCapitalize)
        }
    }

    public var restoreIfWrongSpelling: Bool {
        get {
            lock.lock()
            defer { lock.unlock() }
            return defaults.bool(forKey: SettingsKey.restoreIfWrongSpelling.rawValue)
        }
        set {
            lock.lock()
            defaults.set(newValue, forKey: SettingsKey.restoreIfWrongSpelling.rawValue)
            lock.unlock()
            settingsChangedSubject.send(.restoreIfWrongSpelling)
        }
    }

    // MARK: - App Behavior

    public var smartSwitchEnabled: Bool {
        get {
            lock.lock()
            defer { lock.unlock() }
            return defaults.bool(forKey: SettingsKey.smartSwitchEnabled.rawValue)
        }
        set {
            lock.lock()
            defaults.set(newValue, forKey: SettingsKey.smartSwitchEnabled.rawValue)
            lock.unlock()
            settingsChangedSubject.send(.smartSwitchEnabled)
        }
    }

    public var launchAtLogin: Bool {
        get {
            lock.lock()
            defer { lock.unlock() }
            return defaults.bool(forKey: SettingsKey.launchAtLogin.rawValue)
        }
        set {
            lock.lock()
            defaults.set(newValue, forKey: SettingsKey.launchAtLogin.rawValue)
            lock.unlock()
            settingsChangedSubject.send(.launchAtLogin)

            // Register/unregister login item on main thread
            // Note: SMAppService requires proper code signing, skip in debug builds
            #if !DEBUG
                Task { @MainActor in
                    do {
                        try AppLifecycleManager.shared.setLaunchAtLogin(newValue)
                    } catch {
                        #if DEBUG
                            debugPrint(
                                "[SettingsStore] Failed to update launch at login: \(error.localizedDescription)",
                            )
                        #endif
                    }
                }
            #else
                debugPrint("[SettingsStore] Launch at login is disabled in debug builds (requires code signing)")
            #endif
        }
    }

    public var showDockIcon: Bool {
        get {
            lock.lock()
            defer { lock.unlock() }
            return defaults.bool(forKey: SettingsKey.showDockIcon.rawValue)
        }
        set {
            lock.lock()
            defaults.set(newValue, forKey: SettingsKey.showDockIcon.rawValue)
            lock.unlock()
            settingsChangedSubject.send(.showDockIcon)

            // Update dock icon visibility on main thread
            Task { @MainActor in
                AppLifecycleManager.shared.setDockIconVisible(newValue)
            }
        }
    }

    // MARK: - Advanced Settings

    public var fixBrowserAutocomplete: Bool {
        get {
            lock.lock()
            defer { lock.unlock() }
            return defaults.bool(forKey: SettingsKey.fixBrowserAutocomplete.rawValue)
        }
        set {
            lock.lock()
            defaults.set(newValue, forKey: SettingsKey.fixBrowserAutocomplete.rawValue)
            lock.unlock()
            settingsChangedSubject.send(.fixBrowserAutocomplete)
        }
    }

    public var fixChromiumBrowser: Bool {
        get {
            lock.lock()
            defer { lock.unlock() }
            return defaults.bool(forKey: SettingsKey.fixChromiumBrowser.rawValue)
        }
        set {
            lock.lock()
            defaults.set(newValue, forKey: SettingsKey.fixChromiumBrowser.rawValue)
            lock.unlock()
            settingsChangedSubject.send(.fixChromiumBrowser)
        }
    }

    public var sendKeyStepByStep: Bool {
        get {
            lock.lock()
            defer { lock.unlock() }
            return defaults.bool(forKey: SettingsKey.sendKeyStepByStep.rawValue)
        }
        set {
            lock.lock()
            defaults.set(newValue, forKey: SettingsKey.sendKeyStepByStep.rawValue)
            lock.unlock()
            settingsChangedSubject.send(.sendKeyStepByStep)
        }
    }

    // MARK: - i18n

    public var appLanguage: AppLanguage {
        get {
            lock.lock()
            defer { lock.unlock() }
            let rawValue = defaults.string(forKey: SettingsKey.appLanguage.rawValue) ?? "system"
            return AppLanguage(rawValue: rawValue) ?? .system
        }
        set {
            lock.lock()
            defaults.set(newValue.rawValue, forKey: SettingsKey.appLanguage.rawValue)
            lock.unlock()
            settingsChangedSubject.send(.appLanguage)
        }
    }

    // MARK: - Shortcut

    public var switchLanguageHotkey: UInt32 {
        get {
            lock.lock()
            defer { lock.unlock() }
            let value = defaults.integer(forKey: SettingsKey.switchLanguageHotkey.rawValue)
            return value > 0 ? UInt32(value) : 0x8131 // Default: Ctrl+Space with beep
        }
        set {
            lock.lock()
            defaults.set(Int(newValue), forKey: SettingsKey.switchLanguageHotkey.rawValue)
            lock.unlock()
            settingsChangedSubject.send(.switchLanguageHotkey)
        }
    }

    // MARK: - Reset

    public func resetToDefaults() {
        let keys: [SettingsKey] = [
            .inputMethod, .spellCheckEnabled,
            .smartSwitchEnabled, .quickTelexEnabled,
            .launchAtLogin, .showDockIcon, .autoCapitalize,
            .restoreIfWrongSpelling,
            // Advanced settings
            .fixBrowserAutocomplete, .fixChromiumBrowser,
            .sendKeyStepByStep,
            // i18n
            .appLanguage,
            // Shortcut
            .switchLanguageHotkey,
        ]

        lock.lock()
        for key in keys {
            defaults.removeObject(forKey: key.rawValue)
        }
        lock.unlock()

        registerDefaults()

        for key in keys {
            settingsChangedSubject.send(key)
        }
    }
}
