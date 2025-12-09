@testable import LotusKey
import Testing

// MARK: - Edge Case Tests: Complex Vowel Combinations

struct ComplexVowelTests {
    let spellChecker = DefaultSpellChecker()

    @Test("Parse 'khuya' → kh + uya")
    func khuya() {
        let parts = SyllableParser.parse("khuya")
        #expect(parts != nil)
        #expect(parts?.initialConsonant == "kh")
        #expect(parts?.vowelNucleus == "uya")
        #expect(parts?.finalConsonant.isEmpty == true)
    }

    @Test("Parse 'khuấy' → kh + uay")
    func khuay() {
        let parts = SyllableParser.parse("khuấy")
        #expect(parts != nil)
        #expect(parts?.initialConsonant == "kh")
        // "uấy" = u + â + y = uay with circumflex on a
        #expect(parts?.vowelNucleus == "uay")
    }

    @Test("Parse 'ngoài' → ng + oai")
    func ngoai() {
        let parts = SyllableParser.parse("ngoài")
        #expect(parts != nil)
        #expect(parts?.initialConsonant == "ng")
        #expect(parts?.vowelNucleus == "oai")
        #expect(parts?.tone == .grave)
    }

    @Test("Parse 'xoáy' → x + oay")
    func xoay() {
        let parts = SyllableParser.parse("xoáy")
        #expect(parts != nil)
        #expect(parts?.initialConsonant == "x")
        #expect(parts?.vowelNucleus == "oay")
        #expect(parts?.tone == .acute)
    }

    @Test("Parse 'thoong' (loan word) → th + oo + ng")
    func thoong() {
        let parts = SyllableParser.parse("thoong")
        #expect(parts != nil)
        #expect(parts?.initialConsonant == "th")
        #expect(parts?.vowelNucleus == "oo")
        #expect(parts?.finalConsonant == "ng")
    }

    @Test("Spell check 'khuya' is valid")
    func khuyaValid() {
        let result = spellChecker.check("khuya")
        #expect(result == .valid)
    }

    @Test("Spell check 'ngoài' is valid")
    func ngoaiValid() {
        let result = spellChecker.check("ngoài")
        #expect(result == .valid)
    }

    @Test("Parse 'ươi' (standalone triphthong)")
    func uoi() {
        let parts = SyllableParser.parse("ươi")
        #expect(parts != nil)
        #expect(parts?.initialConsonant.isEmpty == true)
        #expect(parts?.vowelNucleus == "uoi")
        // Both u and o should have horn modifiers
    }

    @Test("Parse 'được' → d + uo + c")
    func duoc() {
        let parts = SyllableParser.parse("được")
        #expect(parts != nil)
        #expect(parts?.initialConsonant == "d")
        #expect(parts?.vowelNucleus == "uo")
        #expect(parts?.finalConsonant == "c")
        #expect(parts?.tone == .dot)
    }

    @Test("Parse 'người' → ng + uoi")
    func nguoi() {
        let parts = SyllableParser.parse("người")
        #expect(parts != nil)
        #expect(parts?.initialConsonant == "ng")
        #expect(parts?.vowelNucleus == "uoi")
    }
}
