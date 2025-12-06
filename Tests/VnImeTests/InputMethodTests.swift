import XCTest
@testable import VnIme

final class InputMethodTests: XCTestCase {
    // MARK: - Telex Tests

    func testTelexToneMarks() {
        let telex = TelexInputMethod()

        // Test tone mark keys
        XCTAssertNotNil(telex.processCharacter("s", context: "a"))  // sắc
        XCTAssertNotNil(telex.processCharacter("f", context: "a"))  // huyền
        XCTAssertNotNil(telex.processCharacter("r", context: "a"))  // hỏi
        XCTAssertNotNil(telex.processCharacter("x", context: "a"))  // ngã
        XCTAssertNotNil(telex.processCharacter("j", context: "a"))  // nặng
        XCTAssertNotNil(telex.processCharacter("z", context: "a"))  // remove tone
    }

    func testTelexModifierMarks() {
        let telex = TelexInputMethod()

        // Test circumflex (aa -> â)
        let aaResult = telex.processCharacter("a", context: "a")
        XCTAssertNotNil(aaResult)
        if case .modifier(.circumflex) = aaResult?.type {
            // Expected
        } else {
            XCTFail("Expected circumflex modifier for 'aa'")
        }

        // Test ee -> ê
        let eeResult = telex.processCharacter("e", context: "e")
        XCTAssertNotNil(eeResult)

        // Test oo -> ô
        let ooResult = telex.processCharacter("o", context: "o")
        XCTAssertNotNil(ooResult)

        // Test dd -> đ
        let ddResult = telex.processCharacter("d", context: "d")
        XCTAssertNotNil(ddResult)
        if case .modifier(.stroke) = ddResult?.type {
            // Expected
        } else {
            XCTFail("Expected stroke modifier for 'dd'")
        }
    }

    func testTelexWKey() {
        let telex = TelexInputMethod()

        // aw -> ă
        let awResult = telex.processCharacter("w", context: "a")
        XCTAssertNotNil(awResult)
        if case .modifier(.breve) = awResult?.type {
            // Expected
        } else {
            XCTFail("Expected breve modifier for 'aw'")
        }

        // uw -> ư
        let uwResult = telex.processCharacter("w", context: "u")
        XCTAssertNotNil(uwResult)
        if case .modifier(.horn) = uwResult?.type {
            // Expected
        } else {
            XCTFail("Expected horn modifier for 'uw'")
        }

        // ow -> ơ
        let owResult = telex.processCharacter("w", context: "o")
        XCTAssertNotNil(owResult)
    }

    func testTelexSpecialKeys() {
        let telex = TelexInputMethod()

        XCTAssertTrue(telex.isSpecialKey("s"))
        XCTAssertTrue(telex.isSpecialKey("f"))
        XCTAssertTrue(telex.isSpecialKey("r"))
        XCTAssertTrue(telex.isSpecialKey("x"))
        XCTAssertTrue(telex.isSpecialKey("j"))
        XCTAssertTrue(telex.isSpecialKey("z"))
        XCTAssertTrue(telex.isSpecialKey("w"))

        XCTAssertFalse(telex.isSpecialKey("a"))
        XCTAssertFalse(telex.isSpecialKey("b"))
        XCTAssertFalse(telex.isSpecialKey("1"))
    }

    // MARK: - Input Method Name Tests

    func testInputMethodNames() {
        XCTAssertEqual(TelexInputMethod().name, "Telex")
    }
}
