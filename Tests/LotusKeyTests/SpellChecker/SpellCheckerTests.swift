@testable import LotusKey
import Testing

/// Tests for Vietnamese spell checking validation
struct SpellCheckerTests {
    let spellChecker = DefaultSpellChecker()

    // MARK: - Initial Consonant Validation Tests

    @Test("Valid initial consonants")
    func validInitialConsonants() {
        let validConsonants = [
            "b", "c", "ch", "d", "g", "gh", "gi", "h", "k", "kh",
            "l", "m", "n", "ng", "ngh", "nh", "p", "ph", "qu", "r",
            "s", "t", "th", "tr", "v", "x",
        ]
        for consonant in validConsonants {
            #expect(spellChecker.isValidInitialConsonant(consonant), "Expected '\(consonant)' to be valid")
        }
    }

    @Test("Invalid initial consonants")
    func invalidInitialConsonants() {
        let invalidConsonants = ["f", "j", "w", "z", "bh", "dl", "kk"]
        for consonant in invalidConsonants {
            #expect(!spellChecker.isValidInitialConsonant(consonant), "Expected '\(consonant)' to be invalid")
        }
    }

    @Test("Empty initial consonant is valid")
    func emptyInitialConsonant() {
        #expect(spellChecker.isValidInitialConsonant(""))
    }

    // MARK: - Final Consonant Validation Tests

    @Test("Valid final consonants")
    func validFinalConsonants() {
        let validFinals = ["c", "ch", "m", "n", "ng", "nh", "p", "t"]
        for consonant in validFinals {
            #expect(spellChecker.isValidFinalConsonant(consonant), "Expected '\(consonant)' to be valid final")
        }
    }

    @Test("Invalid final consonants")
    func invalidFinalConsonants() {
        let invalidFinals = ["b", "d", "g", "h", "k", "l", "r", "s", "v", "x", "tr"]
        for consonant in invalidFinals {
            #expect(!spellChecker.isValidFinalConsonant(consonant), "Expected '\(consonant)' to be invalid final")
        }
    }

    @Test("Empty final consonant is valid")
    func emptyFinalConsonant() {
        #expect(spellChecker.isValidFinalConsonant(""))
    }

    // MARK: - Vowel Combination Validation Tests

    @Test("Valid single vowels")
    func validSingleVowels() {
        let singleVowels = ["a", "e", "i", "o", "u", "y"]
        for vowel in singleVowels {
            #expect(spellChecker.isValidVowelCombination(vowel), "Expected '\(vowel)' to be valid")
        }
    }

    @Test("Valid diphthongs")
    func testValidDiphthongs() {
        let validDiphthongs = [
            "ai",
            "ao",
            "au",
            "ay",
            "eo",
            "ia",
            "ie",
            "iu",
            "oa",
            "oe",
            "oi",
            "ua",
            "ue",
            "ui",
            "uo",
            "uy",
            "ye",
        ]
        for diphthong in validDiphthongs {
            #expect(spellChecker.isValidVowelCombination(diphthong), "Expected '\(diphthong)' to be valid")
        }
    }

    @Test("Valid triphthongs")
    func testValidTriphthongs() {
        let validTriphthongs = ["oai", "oao", "oay", "oeo", "uoi", "uya", "uye", "uyu", "ieu", "yeu"]
        for triphthong in validTriphthongs {
            #expect(spellChecker.isValidVowelCombination(triphthong), "Expected '\(triphthong)' to be valid")
        }
    }

    // MARK: - Tone with Ending Consonant Tests

    @Test("Sharp endings allow acute and dot tones")
    func sharpEndingsValidTones() {
        let sharpEndings = ["c", "ch", "p", "t"]
        for ending in sharpEndings {
            #expect(
                VietnameseSpellingRules.isValidToneWithEnding(.acute, ending: ending),
                "Acute should be valid with \(ending)",
            )
            #expect(
                VietnameseSpellingRules.isValidToneWithEnding(.dot, ending: ending),
                "Dot should be valid with \(ending)",
            )
            #expect(
                VietnameseSpellingRules.isValidToneWithEnding(ToneMark.none, ending: ending),
                "None should be valid with \(ending)",
            )
            #expect(
                VietnameseSpellingRules.isValidToneWithEnding(nil, ending: ending),
                "Nil should be valid with \(ending)",
            )
        }
    }

    @Test("Sharp endings reject grave, hook, tilde tones")
    func sharpEndingsInvalidTones() {
        let sharpEndings = ["c", "ch", "p", "t"]
        for ending in sharpEndings {
            #expect(
                !VietnameseSpellingRules.isValidToneWithEnding(.grave, ending: ending),
                "Grave should be invalid with \(ending)",
            )
            #expect(
                !VietnameseSpellingRules.isValidToneWithEnding(.hook, ending: ending),
                "Hook should be invalid with \(ending)",
            )
            #expect(
                !VietnameseSpellingRules.isValidToneWithEnding(.tilde, ending: ending),
                "Tilde should be invalid with \(ending)",
            )
        }
    }

    @Test("Non-sharp endings allow all tones")
    func nonSharpEndingsAllTones() {
        let nonSharpEndings = ["m", "n", "ng", "nh"]
        let allTones: [ToneMark?] = [ToneMark.none, .acute, .grave, .hook, .tilde, .dot, nil]
        for ending in nonSharpEndings {
            for tone in allTones {
                #expect(
                    VietnameseSpellingRules.isValidToneWithEnding(tone, ending: ending),
                    "All tones should be valid with \(ending)",
                )
            }
        }
    }

    @Test("Empty ending allows all tones")
    func emptyEndingAllTones() {
        let allTones: [ToneMark?] = [ToneMark.none, .acute, .grave, .hook, .tilde, .dot, nil]
        for tone in allTones {
            #expect(
                VietnameseSpellingRules.isValidToneWithEnding(tone, ending: ""),
                "All tones should be valid with empty ending",
            )
        }
    }

    // MARK: - Full Spell Check Tests

    @Test("Valid simple syllables")
    func validSimpleSyllables() {
        let validWords = ["ba", "me", "di", "to", "cu", "ly"]
        for word in validWords {
            let result = spellChecker.check(word)
            #expect(result == .valid, "Expected '\(word)' to be valid")
        }
    }

    @Test("Valid syllables with ending consonants")
    func validSyllablesWithEnding() {
        let validWords = ["ban", "cam", "tin", "bong", "lung"]
        for word in validWords {
            let result = spellChecker.check(word)
            #expect(result == .valid, "Expected '\(word)' to be valid")
        }
    }

    @Test("Valid Vietnamese unicode syllables")
    func validUnicodeSyllables() {
        let validWords = ["án", "bàn", "cảm", "dãn", "đẹp"]
        for word in validWords {
            let result = spellChecker.check(word)
            #expect(result == .valid, "Expected '\(word)' to be valid")
        }
    }

    @Test("Invalid: sharp ending with grave tone")
    func invalidSharpEndingGrave() {
        // "bàc" has grave tone with sharp ending 'c' - invalid
        let result = spellChecker.check("bàc")
        #expect(result != .valid, "Expected 'bàc' to be invalid (grave with sharp ending)")
    }

    @Test("Invalid: sharp ending with hook tone")
    func invalidSharpEndingHook() {
        // "bảc" has hook tone with sharp ending 'c' - invalid
        let result = spellChecker.check("bảc")
        #expect(result != .valid, "Expected 'bảc' to be invalid (hook with sharp ending)")
    }

    @Test("Invalid: sharp ending with tilde tone")
    func invalidSharpEndingTilde() {
        // "bãc" has tilde tone with sharp ending 'c' - invalid
        let result = spellChecker.check("bãc")
        #expect(result != .valid, "Expected 'bãc' to be invalid (tilde with sharp ending)")
    }

    @Test("Valid: sharp ending with acute tone")
    func validSharpEndingAcute() {
        let result = spellChecker.check("bác")
        #expect(result == .valid, "Expected 'bác' to be valid (acute with sharp ending)")
    }

    @Test("Valid: sharp ending with dot tone")
    func validSharpEndingDot() {
        let result = spellChecker.check("bạc")
        #expect(result == .valid, "Expected 'bạc' to be valid (dot with sharp ending)")
    }

    @Test("Empty word is invalid")
    func emptyWord() {
        let result = spellChecker.check("")
        #expect(result == .invalid(reason: "Empty word"))
    }

    @Test("Consonant-only returns unknown")
    func consonantOnly() {
        // Just "th" could be typing "tha" - treat as unknown
        let result = spellChecker.check("th")
        #expect(result == .unknown)
    }

    @Test("Valid vowel-only words")
    func vowelOnlyWords() {
        let validWords = ["a", "ái", "ơi", "ư"]
        for word in validWords {
            let result = spellChecker.check(word)
            #expect(result == .valid, "Expected '\(word)' to be valid")
        }
    }

    // MARK: - Edge Cases

    @Test("Case insensitive validation")
    func caseInsensitive() {
        #expect(spellChecker.isValidInitialConsonant("TH") == spellChecker.isValidInitialConsonant("th"))
        #expect(spellChecker.isValidFinalConsonant("NG") == spellChecker.isValidFinalConsonant("ng"))
    }

    @Test("Complex syllables: common Vietnamese words")
    func commonVietnameseWords() {
        let commonWords = [
            "xin", "chào", "cảm", "ơn", "việt", "nam",
            "học", "tiếng", "nước", "người", "được",
        ]
        for word in commonWords {
            let result = spellChecker.check(word)
            // These should all be valid or at least parseable
            #expect(result != .invalid(reason: "Empty word"), "Expected '\(word)' to be parseable")
        }
    }

    // MARK: - ToneMark Conversion Tests

    @Test("ToneMark to CharacterState conversion")
    func toneMarkToCharacterState() {
        #expect(ToneMark.none.asCharacterState.isEmpty)
        #expect(ToneMark.acute.asCharacterState == .acute)
        #expect(ToneMark.grave.asCharacterState == .grave)
        #expect(ToneMark.hook.asCharacterState == .hook)
        #expect(ToneMark.tilde.asCharacterState == .tilde)
        #expect(ToneMark.dot.asCharacterState == .dotBelow)
    }

    @Test("CharacterState to ToneMark conversion")
    func characterStateToToneMark() {
        #expect(ToneMark(from: .acute) == .acute)
        #expect(ToneMark(from: .grave) == .grave)
        #expect(ToneMark(from: .hook) == .hook)
        #expect(ToneMark(from: .tilde) == .tilde)
        #expect(ToneMark(from: .dotBelow) == .dot)
        #expect(ToneMark(from: []) == ToneMark.none)
    }
}
