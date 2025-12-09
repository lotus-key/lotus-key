@testable import LotusKey
import Testing

/// Tests for Vietnamese syllable parsing
struct SyllableParserTests {
    // MARK: - SyllableParser Tests

    @Test("Parse simple syllable: 'ba'")
    func parseSimpleSyllable() {
        let parts = SyllableParser.parse("ba")
        #expect(parts != nil)
        #expect(parts?.initialConsonant == "b")
        #expect(parts?.vowelNucleus == "a")
        #expect(parts?.finalConsonant.isEmpty == true)
    }

    @Test("Parse syllable with ending consonant: 'ban'")
    func parseSyllableWithEnding() {
        let parts = SyllableParser.parse("ban")
        #expect(parts != nil)
        #expect(parts?.initialConsonant == "b")
        #expect(parts?.vowelNucleus == "a")
        #expect(parts?.finalConsonant == "n")
    }

    @Test("Parse syllable with digraph consonant: 'tha'")
    func parseDigraphConsonant() {
        let parts = SyllableParser.parse("tha")
        #expect(parts != nil)
        #expect(parts?.initialConsonant == "th")
        #expect(parts?.vowelNucleus == "a")
        #expect(parts?.finalConsonant.isEmpty == true)
    }

    @Test("Parse syllable with trigraph: 'nghe'")
    func parseTrigraphConsonant() {
        let parts = SyllableParser.parse("nghe")
        #expect(parts != nil)
        #expect(parts?.initialConsonant == "ngh")
        #expect(parts?.vowelNucleus == "e")
        #expect(parts?.finalConsonant.isEmpty == true)
    }

    @Test("Parse syllable with digraph ending: 'bang'")
    func parseDigraphEnding() {
        let parts = SyllableParser.parse("bang")
        #expect(parts != nil)
        #expect(parts?.initialConsonant == "b")
        #expect(parts?.vowelNucleus == "a")
        #expect(parts?.finalConsonant == "ng")
    }

    @Test("Parse syllable starting with vowel: 'an'")
    func parseVowelStart() {
        let parts = SyllableParser.parse("an")
        #expect(parts != nil)
        #expect(parts?.initialConsonant.isEmpty == true)
        #expect(parts?.vowelNucleus == "a")
        #expect(parts?.finalConsonant == "n")
    }

    @Test("Parse syllable with 'qu' cluster: 'qua'")
    func parseQuCluster() {
        let parts = SyllableParser.parse("qua")
        #expect(parts != nil)
        #expect(parts?.initialConsonant == "qu")
        #expect(parts?.vowelNucleus == "a")
        #expect(parts?.finalConsonant.isEmpty == true)
    }

    @Test("Parse syllable with 'gi' cluster: 'gia'")
    func parseGiCluster() {
        let parts = SyllableParser.parse("gia")
        #expect(parts != nil)
        #expect(parts?.initialConsonant == "gi")
        #expect(parts?.vowelNucleus == "a")
        #expect(parts?.finalConsonant.isEmpty == true)
    }

    @Test("Parse diphthong: 'ai'")
    func parseDiphthong() {
        let parts = SyllableParser.parse("ai")
        #expect(parts != nil)
        #expect(parts?.initialConsonant.isEmpty == true)
        #expect(parts?.vowelNucleus == "ai")
        #expect(parts?.finalConsonant.isEmpty == true)
    }

    @Test("Parse triphthong: 'oai'")
    func parseTriphthong() {
        let parts = SyllableParser.parse("oai")
        #expect(parts != nil)
        #expect(parts?.initialConsonant.isEmpty == true)
        #expect(parts?.vowelNucleus == "oai")
        #expect(parts?.finalConsonant.isEmpty == true)
    }

    @Test("Parse Vietnamese unicode: 'tiến'")
    func parseVietnameseUnicode() {
        let parts = SyllableParser.parse("tiến")
        #expect(parts != nil)
        #expect(parts?.initialConsonant == "t")
        #expect(parts?.vowelNucleus == "ie")
        #expect(parts?.finalConsonant == "n")
        #expect(parts?.tone == .acute)
    }

    @Test("Parse syllable with circumflex: 'ân'")
    func parseCircumflex() {
        let parts = SyllableParser.parse("ân")
        #expect(parts != nil)
        #expect(parts?.initialConsonant.isEmpty == true)
        #expect(parts?.vowelNucleus == "a")
        #expect(parts?.finalConsonant == "n")
        #expect(parts?.vowelModifiers[0] == .circumflex)
    }

    @Test("Parse syllable with horn: 'ơn'")
    func parseHorn() {
        let parts = SyllableParser.parse("ơn")
        #expect(parts != nil)
        #expect(parts?.initialConsonant.isEmpty == true)
        #expect(parts?.vowelNucleus == "o")
        #expect(parts?.finalConsonant == "n")
        #expect(parts?.vowelModifiers[0] == .horn)
    }

    @Test("Parse syllable with breve: 'ăn'")
    func parseBreve() {
        let parts = SyllableParser.parse("ăn")
        #expect(parts != nil)
        #expect(parts?.initialConsonant.isEmpty == true)
        #expect(parts?.vowelNucleus == "a")
        #expect(parts?.finalConsonant == "n")
        #expect(parts?.vowelModifiers[0] == .breve)
    }

    @Test("Parse complex syllable: 'thương'")
    func parseComplex() {
        let parts = SyllableParser.parse("thương")
        #expect(parts != nil)
        #expect(parts?.initialConsonant == "th")
        // Note: after decomposition, "ươ" becomes "uo" with horn modifiers
        #expect(parts?.vowelNucleus == "uo")
        #expect(parts?.finalConsonant == "ng")
    }

    @Test("Parse all tone marks")
    func parseToneMarks() {
        // Acute (sắc)
        let acute = SyllableParser.parse("má")
        #expect(acute?.tone == .acute)

        // Grave (huyền)
        let grave = SyllableParser.parse("mà")
        #expect(grave?.tone == .grave)

        // Hook (hỏi)
        let hook = SyllableParser.parse("mả")
        #expect(hook?.tone == .hook)

        // Tilde (ngã)
        let tilde = SyllableParser.parse("mã")
        #expect(tilde?.tone == .tilde)

        // Dot below (nặng)
        let dot = SyllableParser.parse("mạ")
        #expect(dot?.tone == .dot)

        // No tone (ngang)
        let none = SyllableParser.parse("ma")
        #expect(none?.tone == nil || none?.tone == ToneMark.none)
    }
}
