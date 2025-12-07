import Foundation

/// Localization manager that manually loads strings from the correct lproj
/// This is needed because:
/// - SPM bundles don't respond to AppleLanguages the same way as main bundles
/// - AppleLanguages must be set before ANY Bundle is accessed (very early in startup)
/// - Manual loading gives us precise control over which localization is used
public enum LocalizationManager {

    /// Cache of loaded strings - thread-safe via nonisolated(unsafe) since we only write once at startup
    nonisolated(unsafe) private static var cachedStrings: [String: String]?

    /// Current language code (en or vi)
    private static var currentLanguage: String {
        let stored = UserDefaults.standard.string(forKey: SettingsKey.appLanguage.rawValue) ?? "system"

        if stored == "system" {
            // Get system language, default to en
            let preferred = Locale.preferredLanguages.first ?? "en"
            // Extract language code (e.g., "en-VN" -> "en", "vi-VN" -> "vi")
            let code = String(preferred.prefix(2))
            return code == "vi" ? "vi" : "en"
        }

        return stored
    }

    /// Load strings dictionary from the appropriate lproj folder
    private static func loadStrings() -> [String: String] {
        let lang = currentLanguage

        // Try to load from the current language's lproj
        if let url = Bundle.module.url(forResource: "Localizable", withExtension: "strings", subdirectory: "\(lang).lproj"),
           let strings = NSDictionary(contentsOf: url) as? [String: String] {
            return strings
        }

        // Fallback to English
        if let url = Bundle.module.url(forResource: "Localizable", withExtension: "strings", subdirectory: "en.lproj"),
           let strings = NSDictionary(contentsOf: url) as? [String: String] {
            return strings
        }

        return [:]
    }

    /// Get localized string for key
    public static func localized(_ key: String) -> String {
        // Load strings on first access
        if cachedStrings == nil {
            cachedStrings = loadStrings()
        }

        return cachedStrings?[key] ?? key
    }

    /// Clear cache (call when language changes, before restart)
    public static func invalidateCache() {
        cachedStrings = nil
    }
}

/// Shorthand function for localized strings
/// Usage: L("key") returns the localized string
public func L(_ key: String) -> String {
    LocalizationManager.localized(key)
}
