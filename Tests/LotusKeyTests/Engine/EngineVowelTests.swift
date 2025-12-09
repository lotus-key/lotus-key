import XCTest
@testable import LotusKey

/// Tests for vowel handling including qu-/gi- clusters and triple vowels
final class EngineVowelTests: EngineTestCase {

    // MARK: - qu-/gi- Consonant Handling

    func testQuConsonantMarkPosition() {
        // "quas" -> "quá" - mark on 'a', not 'u'
        let result = engine.processString("quas")
        XCTAssertEqual(result, "quá")
    }

    func testQuyMarkPosition() {
        // "quys" -> "quý" - mark on 'y' (only real vowel)
        let result = engine.processString("quys")
        XCTAssertEqual(result, "quý")
    }

    func testGiaMarkPosition() {
        // "gias" -> "giá" - mark on 'a', not 'i'
        let result = engine.processString("gias")
        XCTAssertEqual(result, "giá")
    }

    func testGiWithoutFollowingVowel() {
        // "gis" -> "gí" - 'i' is treated as vowel when no following vowel
        let result = engine.processString("gis")
        XCTAssertEqual(result, "gí")
    }

    // MARK: - Triple Vowel Tests

    func testTripleVowelUoi() {
        // "tuooir" -> "tưởi" - mark on middle vowel 'ô'
        var buffer = TypingBuffer()
        buffer.append("t")
        buffer.append("u")
        var typedO = TypedCharacter(character: "o")
        typedO.state.insert(.circumflex)  // ô
        buffer.append(typedO)
        buffer.append("i")

        // Mark should go on 'ô' (the modified vowel)
        let markPos = buffer.findMarkPosition()
        XCTAssertEqual(markPos, 2)  // Position of 'ô'
    }

    func testTripleVowelOai() {
        // "oai" -> mark should go on middle vowel 'a'
        var buffer = TypingBuffer()
        buffer.append("o")
        buffer.append("a")
        buffer.append("i")

        let markPos = buffer.findMarkPosition()
        XCTAssertEqual(markPos, 1)  // Position of 'a' (middle)
    }

    // MARK: - iê/yê/uô/ươ + Ending Consonant Integration Tests

    func testIEWithEndingConsonant() {
        // "tieens" -> "tiến" (mark on ê)
        let result = engine.processString("tieens")
        XCTAssertEqual(result, "tiến")
    }

    func testUOWithEndingConsonant() {
        // "cuoons" -> "cuốn" (mark on ô)
        let result = engine.processString("cuoons")
        XCTAssertEqual(result, "cuốn")
    }

    func testUOWithHornAndEnding() {
        // "nuwowcs" -> "nước" (ươ combination, mark on ơ)
        let result = engine.processString("nuwowcs")
        XCTAssertEqual(result, "nước")
    }

    func testDuoc() {
        // "dduwowcj" -> "được" (đđ = đ, ươ, j = nặng on ơ)
        let result = engine.processString("dduwowcj")
        XCTAssertEqual(result, "được")
    }

    // MARK: - ưu Vowel Pattern Tests
    // Bug fix: "uu" pattern (base form of ưu) was missing from spell checker validation

    func testCuuWithTone() {
        // "cuwus" -> "cứu" (tone on ư, the modified vowel)
        let result = engine.processString("cuwus")
        XCTAssertEqual(result, "cứu")
    }

    func testLuuWithTone() {
        // "luwus" -> "lứu"
        let result = engine.processString("luwus")
        XCTAssertEqual(result, "lứu")
    }

    func testHuuWithTone() {
        // "huwuf" -> "hừu"
        let result = engine.processString("huwuf")
        XCTAssertEqual(result, "hừu")
    }

    func testMuuWithTone() {
        // "muwur" -> "mửu"
        let result = engine.processString("muwur")
        XCTAssertEqual(result, "mửu")
    }

    func testUuPatternMarkPosition() {
        // Mark should go on modified vowel (ư), not the plain u
        var buffer = TypingBuffer()
        buffer.append("c")
        var typedU = TypedCharacter(character: "u")
        typedU.state.insert(.hornOrBreve)  // ư
        buffer.append(typedU)
        buffer.append("u")

        let markPos = buffer.findMarkPosition()
        XCTAssertEqual(markPos, 1, "Mark should be on position 1 (ư)")
    }
}

