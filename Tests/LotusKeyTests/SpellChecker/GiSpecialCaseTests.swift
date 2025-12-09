@testable import LotusKey
import Testing

// MARK: - Edge Case Tests: gi- Special Cases

struct GiSpecialCaseTests {
    let spellChecker = DefaultSpellChecker()

    @Test("Parse 'gi' + vowel only: 'già' → gi + a")
    func giVowelOnly() {
        // "già" should parse as: gi (consonant) + a (vowel)
        let parts = SyllableParser.parse("già")
        #expect(parts != nil)
        #expect(parts?.initialConsonant == "gi")
        #expect(parts?.vowelNucleus == "a")
        #expect(parts?.finalConsonant.isEmpty == true)
        #expect(parts?.tone == .grave)
    }

    @Test("Parse 'giếng' - current implementation parses as gi + e + ng")
    func giIeConsonant() {
        // NOTE: Ideally "giếng" should parse as: g + iê + ng (where "i" joins the vowel)
        // However, current implementation parses it as: gi + ê + ng
        // This is a known limitation documented in design.md
        // The spell check still passes because both parses result in valid syllables
        let parts = SyllableParser.parse("giếng")
        #expect(parts != nil)
        // Current implementation behavior:
        #expect(parts?.initialConsonant == "gi")
        #expect(parts?.vowelNucleus == "e")
        #expect(parts?.finalConsonant == "ng")
        #expect(parts?.tone == .acute)
    }

    @Test("Parse 'giết' - current implementation parses as gi + e + t")
    func giet() {
        // NOTE: Similar to "giếng" - ideally g + iê + t, currently gi + ê + t
        let parts = SyllableParser.parse("giết")
        #expect(parts != nil)
        #expect(parts?.initialConsonant == "gi")
        #expect(parts?.vowelNucleus == "e")
        #expect(parts?.finalConsonant == "t")
        #expect(parts?.tone == .acute)
    }

    @Test("Parse 'giếc' - current implementation parses as gi + e + c")
    func giec() {
        // NOTE: Similar to above - known limitation
        let parts = SyllableParser.parse("giếc")
        #expect(parts != nil)
        #expect(parts?.initialConsonant == "gi")
        #expect(parts?.vowelNucleus == "e")
        #expect(parts?.finalConsonant == "c")
    }

    @Test("Spell check 'già' is valid")
    func giaValid() {
        let result = spellChecker.check("già")
        #expect(result == .valid)
    }

    @Test("Spell check 'giếng' is valid")
    func giengValid() {
        // The word should be valid even with current parsing approach
        let result = spellChecker.check("giếng")
        #expect(result == .valid)
    }

    @Test("Spell check 'giết' is valid")
    func gietValid() {
        let result = spellChecker.check("giết")
        #expect(result == .valid)
    }

    @Test("Parse 'giờ' → gi + o (with horn)")
    func gio() {
        let parts = SyllableParser.parse("giờ")
        #expect(parts != nil)
        #expect(parts?.initialConsonant == "gi")
        #expect(parts?.vowelNucleus == "o")
        #expect(parts?.vowelModifiers[0] == .horn)
        #expect(parts?.tone == .grave)
    }

    @Test("Parse 'giữa' → gi + ua (with horn on u)")
    func giua() {
        // "giữa" parses as gi + ưa
        let parts = SyllableParser.parse("giữa")
        #expect(parts != nil)
        #expect(parts?.initialConsonant == "gi")
        // The parser handles this as gi + ua (with horn on u)
        #expect(parts?.vowelNucleus == "ua")
    }
}
