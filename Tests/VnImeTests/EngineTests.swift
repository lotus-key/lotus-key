import XCTest
@testable import VnIme

final class EngineTests: XCTestCase {
    var engine: DefaultVietnameseEngine!

    override func setUp() {
        super.setUp()
        engine = DefaultVietnameseEngine()
    }

    override func tearDown() {
        engine = nil
        super.tearDown()
    }

    // MARK: - Basic Tests

    func testEngineInitialization() {
        XCTAssertNotNil(engine)
        XCTAssertTrue(engine.spellCheckEnabled)
    }

    func testEngineReset() {
        // Engine should reset without error
        engine.reset()
        // Verify engine is still functional after reset
        XCTAssertNotNil(engine.inputMethod)
    }

    func testDefaultInputMethod() {
        // Default should be Telex
        XCTAssertEqual(engine.inputMethod.name, "Telex")
    }

    func testSetInputMethod() {
        // Test switching to a different input method
        let newTelex = TelexInputMethod()
        engine.setInputMethod(newTelex)
        XCTAssertEqual(engine.inputMethod.name, "Telex")
    }

    func testDefaultCharacterTable() {
        // Default should be Unicode (only supported encoding)
        XCTAssertEqual(engine.characterTable.name, "Unicode")
    }

    // MARK: - Engine Result Tests

    func testPassThroughResult() {
        // Non-special keys should pass through
        let result = engine.processKey(keyCode: 0, character: "a", modifiers: 0)
        XCTAssertEqual(result, .passThrough)
    }

    // MARK: - Placeholder Tests for Future Implementation

    func testToneMarkApplication() {
        // TODO: Implement when engine processing is complete
        // Test: "a" + "s" (sắc) -> "á"
    }

    func testModifierMarkApplication() {
        // TODO: Implement when engine processing is complete
        // Test: "a" + "a" -> "â"
        // Test: "d" + "d" -> "đ"
    }

    func testSpellCheckIntegration() {
        // TODO: Implement when spell checking is integrated
    }
}

// MARK: - EngineResult Equatable

extension EngineResult: Equatable {
    public static func == (lhs: EngineResult, rhs: EngineResult) -> Bool {
        switch (lhs, rhs) {
        case (.passThrough, .passThrough):
            return true
        case (.suppress, .suppress):
            return true
        case let (.replace(lhsBackspace, lhsReplacement), .replace(rhsBackspace, rhsReplacement)):
            return lhsBackspace == rhsBackspace && lhsReplacement == rhsReplacement
        default:
            return false
        }
    }
}
