@testable import LotusKey
import Testing

// MARK: - Edge Case Tests: ngh- Trigraph

struct NghTrigraphTests {
    let spellChecker = DefaultSpellChecker()

    @Test("Parse 'nghiêng' → ngh + ie + ng")
    func nghieng() {
        let parts = SyllableParser.parse("nghiêng")
        #expect(parts != nil)
        #expect(parts?.initialConsonant == "ngh")
        #expect(parts?.vowelNucleus == "ie")
        #expect(parts?.finalConsonant == "ng")
    }

    @Test("Parse 'nghiệp' → ngh + ie + p")
    func nghiep() {
        let parts = SyllableParser.parse("nghiệp")
        #expect(parts != nil)
        #expect(parts?.initialConsonant == "ngh")
        #expect(parts?.vowelNucleus == "ie")
        #expect(parts?.finalConsonant == "p")
        #expect(parts?.tone == .dot)
    }

    @Test("Parse 'nghĩa' → ngh + i + a")
    func nghia() {
        let parts = SyllableParser.parse("nghĩa")
        #expect(parts != nil)
        #expect(parts?.initialConsonant == "ngh")
        #expect(parts?.vowelNucleus == "ia")
        #expect(parts?.tone == .tilde)
    }

    @Test("Parse 'nghệ' → ngh + e")
    func nghe() {
        let parts = SyllableParser.parse("nghệ")
        #expect(parts != nil)
        #expect(parts?.initialConsonant == "ngh")
        #expect(parts?.vowelNucleus == "e")
        #expect(parts?.vowelModifiers[0] == .circumflex)
        #expect(parts?.tone == .dot)
    }

    @Test("Spell check 'nghiêng' is valid")
    func nghiengValid() {
        let result = spellChecker.check("nghiêng")
        #expect(result == .valid)
    }

    @Test("Spell check 'nghiệp' is valid")
    func nghiepValid() {
        let result = spellChecker.check("nghiệp")
        #expect(result == .valid)
    }
}
