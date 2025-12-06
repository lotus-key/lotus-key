import Foundation

/// Result of spell checking a Vietnamese word
public enum SpellCheckResult: Sendable {
    /// The word is valid Vietnamese
    case valid
    /// The word is invalid (with reason)
    case invalid(reason: String)
    /// Unable to determine validity
    case unknown
}

/// Protocol for Vietnamese spell checking
public protocol SpellChecker: Sendable {
    /// Check if a Vietnamese word/syllable is valid
    /// - Parameter word: The word to check
    /// - Returns: The spell check result
    func check(_ word: String) -> SpellCheckResult

    /// Check if a consonant cluster is valid at the start of a syllable
    /// - Parameter consonants: The consonant cluster
    /// - Returns: True if valid
    func isValidInitialConsonant(_ consonants: String) -> Bool

    /// Check if a vowel combination is valid
    /// - Parameter vowels: The vowel combination
    /// - Returns: True if valid
    func isValidVowelCombination(_ vowels: String) -> Bool

    /// Check if a consonant is valid at the end of a syllable
    /// - Parameter consonant: The final consonant
    /// - Returns: True if valid
    func isValidFinalConsonant(_ consonant: String) -> Bool
}

/// Default Vietnamese spell checker implementation
public struct DefaultSpellChecker: SpellChecker {
    // Valid initial consonants in Vietnamese
    private let validInitials: Set<String> = [
        "b", "c", "ch", "d", "đ", "g", "gh", "gi", "h", "k", "kh",
        "l", "m", "n", "ng", "ngh", "nh", "p", "ph", "qu", "r",
        "s", "t", "th", "tr", "v", "x"
    ]

    // Valid final consonants in Vietnamese
    private let validFinals: Set<String> = [
        "c", "ch", "m", "n", "ng", "nh", "p", "t"
    ]

    public init() {}

    public func check(_ word: String) -> SpellCheckResult {
        // TODO: Implement full Vietnamese syllable validation
        // This requires parsing the syllable into initial consonant,
        // vowel nucleus, tone mark, and final consonant
        guard !word.isEmpty else {
            return .invalid(reason: "Empty word")
        }

        return .unknown
    }

    public func isValidInitialConsonant(_ consonants: String) -> Bool {
        consonants.isEmpty || validInitials.contains(consonants.lowercased())
    }

    public func isValidVowelCombination(_ vowels: String) -> Bool {
        // TODO: Implement vowel combination validation
        // Valid combinations depend on the initial consonant and tone rules
        !vowels.isEmpty
    }

    public func isValidFinalConsonant(_ consonant: String) -> Bool {
        consonant.isEmpty || validFinals.contains(consonant.lowercased())
    }
}
