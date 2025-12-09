@testable import LotusKey
import Testing

// MARK: - Edge Case Tests: đ (d-stroke) Handling

struct DStrokeTests {
    let spellChecker = DefaultSpellChecker()

    @Test("Parse 'đi' → d + i")
    func di() {
        let parts = SyllableParser.parse("đi")
        #expect(parts != nil)
        // đ decomposes to 'd'
        #expect(parts?.initialConsonant == "d")
        #expect(parts?.vowelNucleus == "i")
    }

    @Test("Parse 'đường' → d + uo + ng")
    func duong() {
        let parts = SyllableParser.parse("đường")
        #expect(parts != nil)
        #expect(parts?.initialConsonant == "d")
        #expect(parts?.vowelNucleus == "uo")
        #expect(parts?.finalConsonant == "ng")
    }

    @Test("Parse 'đẹp' → d + e + p")
    func dep() {
        let parts = SyllableParser.parse("đẹp")
        #expect(parts != nil)
        #expect(parts?.initialConsonant == "d")
        #expect(parts?.vowelNucleus == "e")
        #expect(parts?.finalConsonant == "p")
        #expect(parts?.tone == .dot)
    }

    @Test("Spell check 'đi' is valid")
    func diValid() {
        let result = spellChecker.check("đi")
        #expect(result == .valid)
    }

    @Test("Spell check 'đẹp' is valid")
    func depValid() {
        let result = spellChecker.check("đẹp")
        #expect(result == .valid)
    }
}
