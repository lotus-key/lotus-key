import Foundation

/// Result of spell checking a Vietnamese word
public enum SpellCheckResult: Sendable, Equatable {
    /// The word is invalid (with reason)
    case invalid(reason: String)
    /// Unable to determine validity (e.g., incomplete input)
    case unknown
    /// The word is valid Vietnamese
    case valid
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

// MARK: - Syllable Parts

/// Parsed representation of a Vietnamese syllable structure.
///
/// Vietnamese syllables follow the pattern: [Initial Consonant] + Vowel Nucleus + [Final Consonant]
/// Examples:
/// - "thuong" → initial: "th", vowel: "uo", final: "ng", tone: none
/// - "tiến" → initial: "t", vowel: "ie", final: "n", tone: acute on 'e'
/// - "ái" → initial: "", vowel: "ai", final: "", tone: acute on 'a'
public struct SyllableParts: Sendable, Equatable {
    /// Initial consonant cluster ("", "b", "ch", "ngh", etc.)
    public let initialConsonant: String

    /// Vowel nucleus ("a", "oa", "ươi", etc.) - stored as base vowels
    public let vowelNucleus: String

    /// Final consonant ("", "n", "ng", "ch", etc.)
    public let finalConsonant: String

    /// The detected tone mark (if any)
    public let tone: ToneMark?

    /// Vowel modifiers by position in vowelNucleus (index → modifier type)
    public let vowelModifiers: [Int: VowelModifier]

    public init(
        initialConsonant: String = "",
        vowelNucleus: String = "",
        finalConsonant: String = "",
        tone: ToneMark? = nil,
        vowelModifiers: [Int: VowelModifier] = [:],
    ) {
        self.initialConsonant = initialConsonant
        self.vowelNucleus = vowelNucleus
        self.finalConsonant = finalConsonant
        self.tone = tone
        self.vowelModifiers = vowelModifiers
    }
}

/// Vowel modifier types in Vietnamese
public enum VowelModifier: Sendable, Equatable {
    /// Breve for ă
    case breve
    /// Circumflex (^) for â, ê, ô
    case circumflex
    /// Horn for ơ, ư
    case horn
}

// Note: ToneMark enum is defined in InputMethod.swift to avoid duplication

// MARK: - Syllable Parser

/// Parses Vietnamese text into syllable components.
public enum SyllableParser {
    /// Parse a Vietnamese word into its syllable parts
    /// - Parameter word: The word to parse (can include Vietnamese Unicode characters)
    /// - Returns: Parsed syllable parts, or nil if parsing fails
    public static func parse(_ word: String) -> SyllableParts? {
        guard !word.isEmpty else { return nil }

        let normalized = word.lowercased()

        // Convert Vietnamese characters to base + modifiers
        var baseChars: [Character] = []
        var modifiers: [Int: VowelModifier] = [:]
        var tone: ToneMark?

        for char in normalized {
            if let (base, modifier, charTone) = decomposeVietnameseChar(char) {
                let index = baseChars.count
                baseChars.append(base)
                if let mod = modifier {
                    modifiers[index] = mod
                }
                if let charToneValue = charTone, charToneValue != .none {
                    tone = charToneValue
                }
            } else {
                baseChars.append(char)
            }
        }

        let baseString = String(baseChars)

        // Extract initial consonant
        let (initial, afterInitial) = extractInitialConsonant(baseString)

        // Extract final consonant (from the end)
        let (vowelPart, final) = extractFinalConsonant(afterInitial)

        // Adjust modifier indices to be relative to vowel nucleus
        var vowelModifiers: [Int: VowelModifier] = [:]
        let initialLength = initial.count
        for (index, mod) in modifiers {
            let vowelIndex = index - initialLength
            if vowelIndex >= 0, vowelIndex < vowelPart.count {
                vowelModifiers[vowelIndex] = mod
            }
        }

        return SyllableParts(
            initialConsonant: initial,
            vowelNucleus: vowelPart,
            finalConsonant: final,
            tone: tone,
            vowelModifiers: vowelModifiers,
        )
    }

    // swiftlint:disable function_body_length
    /// Decompose a Vietnamese character into base + modifier + tone
    private static func decomposeVietnameseChar(_ char: Character) -> (Character, VowelModifier?, ToneMark?)? {
        // Map Vietnamese vowels to base + modifier + tone
        switch char {
        // a variants
        case "a": ("a", nil, ToneMark.none)
        case "á": ("a", nil, .acute)
        case "à": ("a", nil, .grave)
        case "ả": ("a", nil, .hook)
        case "ã": ("a", nil, .tilde)
        case "ạ": ("a", nil, .dot)
        // ă variants (breve)
        case "ă": ("a", .breve, ToneMark.none)
        case "ắ": ("a", .breve, .acute)
        case "ằ": ("a", .breve, .grave)
        case "ẳ": ("a", .breve, .hook)
        case "ẵ": ("a", .breve, .tilde)
        case "ặ": ("a", .breve, .dot)
        // â variants (circumflex)
        case "â": ("a", .circumflex, ToneMark.none)
        case "ấ": ("a", .circumflex, .acute)
        case "ầ": ("a", .circumflex, .grave)
        case "ẩ": ("a", .circumflex, .hook)
        case "ẫ": ("a", .circumflex, .tilde)
        case "ậ": ("a", .circumflex, .dot)
        // e variants
        case "e": ("e", nil, ToneMark.none)
        case "é": ("e", nil, .acute)
        case "è": ("e", nil, .grave)
        case "ẻ": ("e", nil, .hook)
        case "ẽ": ("e", nil, .tilde)
        case "ẹ": ("e", nil, .dot)
        // ê variants (circumflex)
        case "ê": ("e", .circumflex, ToneMark.none)
        case "ế": ("e", .circumflex, .acute)
        case "ề": ("e", .circumflex, .grave)
        case "ể": ("e", .circumflex, .hook)
        case "ễ": ("e", .circumflex, .tilde)
        case "ệ": ("e", .circumflex, .dot)
        // i variants
        case "i": ("i", nil, ToneMark.none)
        case "í": ("i", nil, .acute)
        case "ì": ("i", nil, .grave)
        case "ỉ": ("i", nil, .hook)
        case "ĩ": ("i", nil, .tilde)
        case "ị": ("i", nil, .dot)
        // o variants
        case "o": ("o", nil, ToneMark.none)
        case "ó": ("o", nil, .acute)
        case "ò": ("o", nil, .grave)
        case "ỏ": ("o", nil, .hook)
        case "õ": ("o", nil, .tilde)
        case "ọ": ("o", nil, .dot)
        // ô variants (circumflex)
        case "ô": ("o", .circumflex, ToneMark.none)
        case "ố": ("o", .circumflex, .acute)
        case "ồ": ("o", .circumflex, .grave)
        case "ổ": ("o", .circumflex, .hook)
        case "ỗ": ("o", .circumflex, .tilde)
        case "ộ": ("o", .circumflex, .dot)
        // ơ variants (horn)
        case "ơ": ("o", .horn, ToneMark.none)
        case "ớ": ("o", .horn, .acute)
        case "ờ": ("o", .horn, .grave)
        case "ở": ("o", .horn, .hook)
        case "ỡ": ("o", .horn, .tilde)
        case "ợ": ("o", .horn, .dot)
        // u variants
        case "u": ("u", nil, ToneMark.none)
        case "ú": ("u", nil, .acute)
        case "ù": ("u", nil, .grave)
        case "ủ": ("u", nil, .hook)
        case "ũ": ("u", nil, .tilde)
        case "ụ": ("u", nil, .dot)
        // ư variants (horn)
        case "ư": ("u", .horn, ToneMark.none)
        case "ứ": ("u", .horn, .acute)
        case "ừ": ("u", .horn, .grave)
        case "ử": ("u", .horn, .hook)
        case "ữ": ("u", .horn, .tilde)
        case "ự": ("u", .horn, .dot)
        // y variants
        case "y": ("y", nil, ToneMark.none)
        case "ý": ("y", nil, .acute)
        case "ỳ": ("y", nil, .grave)
        case "ỷ": ("y", nil, .hook)
        case "ỹ": ("y", nil, .tilde)
        case "ỵ": ("y", nil, .dot)
        // đ (consonant with stroke)
        case "đ": ("d", nil, nil)
        // Regular consonants
        case "b", "c", "d", "g", "h", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "x":
            (char, nil, nil)
        default:
            nil
        }
    }

    // swiftlint:enable function_body_length

    /// Extract initial consonant from the beginning of a word
    /// - Returns: (initial consonant, remaining string)
    private static func extractInitialConsonant(_ word: String) -> (String, String) {
        let chars = Array(word)
        guard !chars.isEmpty else { return ("", "") }

        // Check for trigraphs first (ngh)
        if chars.count >= 3 {
            let trigraph = String(chars[0 ... 2])
            if trigraph == "ngh" {
                return (trigraph, String(chars.dropFirst(3)))
            }
        }

        // Check for digraphs (ch, gh, gi, kh, ng, nh, ph, qu, th, tr)
        if chars.count >= 2 {
            let digraph = String(chars[0 ... 1])
            if VietnameseSpellingRules.initialConsonants.contains(digraph) {
                // Special handling for "gi" and "qu"
                if digraph == "gi" {
                    // "gi" followed by vowel+consonant: "g" is consonant, "i" starts vowel
                    // "gi" followed by vowel only: "gi" is consonant
                    // Check what follows
                    let remaining = String(chars.dropFirst(2))
                    if
                        !remaining.isEmpty,
                        let firstRemaining = remaining.first
                    {
                        // If followed by vowel and there's more after, check for consonant ending
                        if VietnameseSpellingRules.baseVowels.contains(firstRemaining) {
                            // "gi" + vowel: "gi" is the consonant
                            return (digraph, remaining)
                        } else if firstRemaining == "e" || firstRemaining == "ê" {
                            // "giê" pattern - "g" is consonant, "iê" is vowel
                            return ("g", String(chars.dropFirst(1)))
                        }
                    }
                    // Default: treat "gi" as consonant
                    return (digraph, remaining)
                } else if digraph == "qu" {
                    // "qu" always absorbs the "u" as part of consonant
                    return (digraph, String(chars.dropFirst(2)))
                }
                return (digraph, String(chars.dropFirst(2)))
            }
        }

        // Check for single consonant
        let first = chars[0]
        if !VietnameseSpellingRules.baseVowels.contains(first) {
            return (String(first), String(chars.dropFirst(1)))
        }

        // Starts with vowel
        return ("", word)
    }

    /// Extract final consonant from the end of a vowel+consonant string
    /// - Returns: (vowel part, final consonant)
    private static func extractFinalConsonant(_ str: String) -> (String, String) {
        let chars = Array(str)
        guard chars.count >= 2 else { return (str, "") }

        // Check for digraph endings (ch, ng, nh)
        if chars.count >= 2 {
            let lastTwo = String(chars.suffix(2))
            if VietnameseSpellingRules.finalConsonants.contains(lastTwo) {
                // Verify the rest is vowels
                let vowelPart = String(chars.dropLast(2))
                if isAllVowels(vowelPart) {
                    return (vowelPart, lastTwo)
                }
            }
        }

        // Check for single consonant ending
        guard let last = chars.last else { return (str, "") }
        if
            !VietnameseSpellingRules.baseVowels.contains(last),
            VietnameseSpellingRules.finalConsonants.contains(String(last))
        {
            let vowelPart = String(chars.dropLast(1))
            if isAllVowels(vowelPart) {
                return (vowelPart, String(last))
            }
        }

        // No ending consonant
        return (str, "")
    }

    /// Check if a string contains only vowels
    private static func isAllVowels(_ str: String) -> Bool {
        str.allSatisfy { VietnameseSpellingRules.baseVowels.contains($0) }
    }
}

// MARK: - Vietnamese Spelling Rules

/// Static lookup tables for Vietnamese spelling validation.
///
/// Based on OpenKey's `_consonantTable`, `_vowelCombine`, and `_endConsonantTable`.
public enum VietnameseSpellingRules {
    /// Base vowels in Vietnamese (lowercase)
    public static let baseVowels: Set<Character> = ["a", "e", "i", "o", "u", "y"]

    /// Valid initial consonant clusters (26 patterns from OpenKey _consonantTable)
    public static let initialConsonants: Set<String> = [
        "b", "c", "ch", "d", "g", "gh", "gi", "h", "k", "kh",
        "l", "m", "n", "ng", "ngh", "nh", "p", "ph", "qu", "r",
        "s", "t", "th", "tr", "v", "x",
    ]

    /// Valid final consonants (8 patterns from OpenKey _endConsonantTable)
    public static let finalConsonants: Set<String> = [
        "c", "ch", "m", "n", "ng", "nh", "p", "t",
    ]

    /// "Sharp" ending consonants - only sắc(´) and nặng(.) tones valid
    public static let sharpEndConsonants: Set<String> = [
        "c", "ch", "p", "t",
    ]

    /// Vowel combinations that do NOT allow ending consonants
    /// From OpenKey _vowelCombine with allowsEndConsonant = 0
    public static let vowelCombinationsNoEnding: Set<String> = [
        // a-based
        "ai", "ao", "au", "ay",
        // â-based
        "âu", "ây",
        // e-based
        "eo",
        // ê-based
        "êu",
        // i-based
        "ia", "iu",
        // o-based
        "oi", "oai", "oao", "oay", "oeo",
        // ô-based
        "ôi",
        // ơ-based
        "ơi",
        // u-based
        "ui", "uyu", "uya", "uây", "uao",
        // ư-based
        "ưi", "ươu", "ươi", "uôi", "ưu",
        // y-based
        "yêu",
    ]

    /// Vowel combinations that ALLOW ending consonants
    /// From OpenKey _vowelCombine with allowsEndConsonant = 1
    public static let vowelCombinationsWithEnding: Set<String> = [
        // i-based
        "iê", "iêu",
        // o-based
        "oa", "oă", "oe", "oo", "ôô",
        // u-based
        "ua", "ưa", "uâ", "uê", "uo", "uô", "ươ", "uy", "uyê",
        // y-based
        "yê",
    ]

    /// All valid vowel combinations (union of both sets plus single vowels)
    public static let allVowelCombinations: Set<String> = {
        var all = vowelCombinationsNoEnding.union(vowelCombinationsWithEnding)
        // Add single vowels
        all.formUnion(["a", "ă", "â", "e", "ê", "i", "o", "ô", "ơ", "u", "ư", "y"])
        return all
    }()

    /// Detailed vowel combination info with end-consonant compatibility
    /// Key: normalized vowel pattern (base vowels only)
    /// Value: (allowsEndConsonant, requiredModifiers)
    public static let vowelCombinationInfo: [String: VowelCombinationInfo] = [
        // Single vowels - all allow endings
        "a": VowelCombinationInfo(allowsEndConsonant: true, modifierPattern: [:]),
        "e": VowelCombinationInfo(allowsEndConsonant: true, modifierPattern: [:]),
        "i": VowelCombinationInfo(allowsEndConsonant: true, modifierPattern: [:]),
        "o": VowelCombinationInfo(allowsEndConsonant: true, modifierPattern: [:]),
        "u": VowelCombinationInfo(allowsEndConsonant: true, modifierPattern: [:]),
        "y": VowelCombinationInfo(allowsEndConsonant: true, modifierPattern: [:]),

        // a-based diphthongs (no ending)
        "ai": VowelCombinationInfo(allowsEndConsonant: false, modifierPattern: [:]),
        "ao": VowelCombinationInfo(allowsEndConsonant: false, modifierPattern: [:]),
        "au": VowelCombinationInfo(allowsEndConsonant: false, modifierPattern: [:]),
        "ay": VowelCombinationInfo(allowsEndConsonant: false, modifierPattern: [:]),

        // â-based (circumflex on a)
        // Note: stored as "a" with circumflex modifier
        // âu, ây - no ending

        // e-based
        "eo": VowelCombinationInfo(allowsEndConsonant: false, modifierPattern: [:]),

        // i-based
        "ia": VowelCombinationInfo(allowsEndConsonant: false, modifierPattern: [:]),
        "ie": VowelCombinationInfo(allowsEndConsonant: true, modifierPattern: [1: .circumflex]), // iê
        "iu": VowelCombinationInfo(allowsEndConsonant: false, modifierPattern: [:]),
        "ieu": VowelCombinationInfo(allowsEndConsonant: false, modifierPattern: [1: .circumflex]), // iêu

        // o-based
        "oa": VowelCombinationInfo(allowsEndConsonant: true, modifierPattern: [:]),
        "oe": VowelCombinationInfo(allowsEndConsonant: true, modifierPattern: [:]),
        "oi": VowelCombinationInfo(allowsEndConsonant: false, modifierPattern: [:]),
        "oo": VowelCombinationInfo(allowsEndConsonant: true, modifierPattern: [:]),
        "oai": VowelCombinationInfo(allowsEndConsonant: false, modifierPattern: [:]),
        "oao": VowelCombinationInfo(allowsEndConsonant: false, modifierPattern: [:]),
        "oay": VowelCombinationInfo(allowsEndConsonant: false, modifierPattern: [:]),
        "oeo": VowelCombinationInfo(allowsEndConsonant: false, modifierPattern: [:]),

        // u-based
        "ua": VowelCombinationInfo(allowsEndConsonant: true, modifierPattern: [:]),
        "ue": VowelCombinationInfo(allowsEndConsonant: true, modifierPattern: [1: .circumflex]), // uê
        "ui": VowelCombinationInfo(allowsEndConsonant: false, modifierPattern: [:]),
        "uo": VowelCombinationInfo(allowsEndConsonant: true, modifierPattern: [1: .circumflex]), // uô
        "uy": VowelCombinationInfo(allowsEndConsonant: true, modifierPattern: [:]),
        "uao": VowelCombinationInfo(allowsEndConsonant: false, modifierPattern: [:]),
        "uay": VowelCombinationInfo(allowsEndConsonant: false, modifierPattern: [:]),
        "uoi": VowelCombinationInfo(allowsEndConsonant: false, modifierPattern: [1: .circumflex]), // uôi
        "uyu": VowelCombinationInfo(allowsEndConsonant: false, modifierPattern: [:]),
        "uya": VowelCombinationInfo(allowsEndConsonant: false, modifierPattern: [:]),
        "uye": VowelCombinationInfo(allowsEndConsonant: true, modifierPattern: [2: .circumflex]), // uyê

        // ưu combination (ư + u = horn on first u)
        // Base pattern is "uu" - first u has horn modifier → "ưu"
        // Examples: cưu, hưu, lưu, mưu, thừu
        "uu": VowelCombinationInfo(allowsEndConsonant: false, modifierPattern: [0: .horn]), // ưu

        // ư-based (horn on u)
        // ưa: u with horn + a
        // ươ: u with horn + o with horn
        // ưu: u with horn + u
        // ươi: u with horn + o with horn + i
        // ươu: u with horn + o with horn + u

        // y-based
        "ye": VowelCombinationInfo(allowsEndConsonant: true, modifierPattern: [1: .circumflex]), // yê
        "yeu": VowelCombinationInfo(allowsEndConsonant: false, modifierPattern: [1: .circumflex]), // yêu
    ]

    /// Check if tone is valid with given ending consonant
    /// Sharp endings (c, ch, p, t) only allow acute and dot-below tones
    public static func isValidToneWithEnding(_ tone: ToneMark?, ending: String) -> Bool {
        guard !ending.isEmpty else { return true }

        let isSharp = sharpEndConsonants.contains(ending.lowercased())

        guard isSharp else { return true }

        // Sharp endings only allow acute, dot, or none
        guard let tone else { return true }
        switch tone {
        case .none, .acute, .dot:
            return true
        case .grave, .hook, .tilde:
            return false
        }
    }
}

/// Information about a vowel combination
public struct VowelCombinationInfo: Sendable, Equatable {
    /// Whether this combination can be followed by an ending consonant
    public let allowsEndConsonant: Bool

    /// Required modifiers at specific positions (0-indexed)
    /// e.g., for "iê": [1: .circumflex] means position 1 must have circumflex
    public let modifierPattern: [Int: VowelModifier]

    public init(allowsEndConsonant: Bool, modifierPattern: [Int: VowelModifier]) {
        self.allowsEndConsonant = allowsEndConsonant
        self.modifierPattern = modifierPattern
    }
}

// MARK: - Default Spell Checker Implementation

/// Default Vietnamese spell checker implementation using phonological rules.
public struct DefaultSpellChecker: SpellChecker {
    public init() {}

    public func check(_ word: String) -> SpellCheckResult {
        guard !word.isEmpty else {
            return .invalid(reason: "Empty word")
        }

        // Parse syllable structure
        guard let parts = SyllableParser.parse(word) else {
            return .unknown
        }

        // Allow consonant-only incomplete input (e.g., "th" while typing "tha")
        if parts.vowelNucleus.isEmpty {
            if parts.initialConsonant.isEmpty {
                return .invalid(reason: "No vowel or consonant")
            }
            // Just consonant - could be incomplete, treat as unknown
            return .unknown
        }

        // 1. Validate initial consonant
        if !parts.initialConsonant.isEmpty {
            if !isValidInitialConsonant(parts.initialConsonant) {
                return .invalid(reason: "Invalid initial consonant: \(parts.initialConsonant)")
            }
        }

        // 2. Validate vowel combination
        if !isValidVowelCombinationWithModifiers(parts.vowelNucleus, modifiers: parts.vowelModifiers) {
            return .invalid(reason: "Invalid vowel combination: \(parts.vowelNucleus)")
        }

        // 3. Validate final consonant
        if !parts.finalConsonant.isEmpty {
            if !isValidFinalConsonant(parts.finalConsonant) {
                return .invalid(reason: "Invalid final consonant: \(parts.finalConsonant)")
            }

            // Check if vowel combination allows ending consonant
            if !vowelAllowsEnding(parts.vowelNucleus, modifiers: parts.vowelModifiers) {
                return .invalid(reason: "Vowel '\(parts.vowelNucleus)' cannot have ending consonant")
            }
        }

        // 4. Validate tone with ending consonant
        if let tone = parts.tone {
            if !VietnameseSpellingRules.isValidToneWithEnding(tone, ending: parts.finalConsonant) {
                return .invalid(reason: "Invalid tone with sharp ending")
            }
        }

        return .valid
    }

    public func isValidInitialConsonant(_ consonants: String) -> Bool {
        consonants.isEmpty || VietnameseSpellingRules.initialConsonants.contains(consonants.lowercased())
    }

    public func isValidVowelCombination(_ vowels: String) -> Bool {
        guard !vowels.isEmpty else { return false }

        let normalized = vowels.lowercased()

        // Check in our known combinations
        if VietnameseSpellingRules.vowelCombinationInfo[normalized] != nil {
            return true
        }

        // Check if it's a single vowel
        if
            normalized.count == 1,
            let first = normalized.first,
            VietnameseSpellingRules.baseVowels.contains(first)
        {
            return true
        }

        return false
    }

    /// Validate vowel combination with modifier information
    private func isValidVowelCombinationWithModifiers(_ vowels: String, modifiers _: [Int: VowelModifier]) -> Bool {
        guard !vowels.isEmpty else { return false }

        let normalized = vowels.lowercased()

        // Single vowel is always valid
        if
            normalized.count == 1,
            let first = normalized.first,
            VietnameseSpellingRules.baseVowels.contains(first)
        {
            return true
        }

        // Check against known combinations
        if VietnameseSpellingRules.vowelCombinationInfo[normalized] != nil {
            return true
        }

        // Check with common Vietnamese vowel patterns
        // Note: "uu" is the base form of "ưu" (horn on first u)
        let validPatterns: Set<String> = [
            "a", "e", "i", "o", "u", "y",
            "ai", "ao", "au", "ay", "ia", "ie", "iu", "oa", "oe", "oi", "oo",
            "ua", "ue", "ui", "uo", "uy", "uu", "ye", // "uu" for ưu pattern
            "oai", "oao", "oay", "oeo", "uoi", "uya", "uye", "uyu", "uao", "uay",
            "ieu", "yeu",
        ]

        return validPatterns.contains(normalized)
    }

    /// Check if vowel combination allows ending consonant
    private func vowelAllowsEnding(_ vowels: String, modifiers _: [Int: VowelModifier]) -> Bool {
        let normalized = vowels.lowercased()

        // Single vowels always allow endings
        if normalized.count == 1 {
            return true
        }

        // Check combination info
        if let info = VietnameseSpellingRules.vowelCombinationInfo[normalized] {
            return info.allowsEndConsonant
        }

        // Default: check if it's NOT in the no-ending set
        return !VietnameseSpellingRules.vowelCombinationsNoEnding.contains(normalized)
    }

    public func isValidFinalConsonant(_ consonant: String) -> Bool {
        consonant.isEmpty || VietnameseSpellingRules.finalConsonants.contains(consonant.lowercased())
    }
}

// MARK: - CharacterState to ToneMark Conversion

public extension ToneMark {
    /// Create ToneMark from CharacterState
    init?(from state: CharacterState) {
        if state.contains(.acute) { self = .acute } else if state.contains(.grave) { self = .grave }
        else if state.contains(.hook) { self = .hook } else if state.contains(.tilde) { self = .tilde }
        else if state.contains(.dotBelow) { self = .dot } else if state.hasToneMark { return nil }
        else { self = .none }
    }

    /// Convert to CharacterState
    var asCharacterState: CharacterState {
        switch self {
        case .none: []
        case .acute: .acute
        case .grave: .grave
        case .hook: .hook
        case .tilde: .tilde
        case .dot: .dotBelow
        }
    }
}
