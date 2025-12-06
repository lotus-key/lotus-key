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
        XCTAssertTrue(telex.isSpecialKey("["))
        XCTAssertTrue(telex.isSpecialKey("]"))

        XCTAssertFalse(telex.isSpecialKey("a"))
        XCTAssertFalse(telex.isSpecialKey("b"))
        XCTAssertFalse(telex.isSpecialKey("1"))
    }

    // MARK: - Input Method Name Tests

    func testInputMethodNames() {
        XCTAssertEqual(TelexInputMethod().name, "Telex")
        XCTAssertEqual(SimpleTelexInputMethod().name, "Simple Telex")
    }

    // MARK: - Bracket Key Tests

    func testBracketKeyAtStart() {
        let telex = TelexInputMethod()

        // [ at start → ơ
        let bracketOpenResult = telex.processCharacter("[", context: "")
        XCTAssertNotNil(bracketOpenResult)
        if case .standalone(let char) = bracketOpenResult?.type {
            XCTAssertEqual(char, "ơ")
        } else {
            XCTFail("Expected standalone ơ for '[' at start")
        }

        // ] at start → ư
        let bracketCloseResult = telex.processCharacter("]", context: "")
        XCTAssertNotNil(bracketCloseResult)
        if case .standalone(let char) = bracketCloseResult?.type {
            XCTAssertEqual(char, "ư")
        } else {
            XCTFail("Expected standalone ư for ']' at start")
        }
    }

    func testBracketKeyAfterConsonant() {
        let telex = TelexInputMethod()

        // b[ → bơ
        let result = telex.processCharacter("[", context: "b")
        XCTAssertNotNil(result)
        if case .standalone(let char) = result?.type {
            XCTAssertEqual(char, "ơ")
        } else {
            XCTFail("Expected standalone ơ for 'b['")
        }
    }

    func testBracketKeyAfterVowelLiteral() {
        let telex = TelexInputMethod()

        // a[ → a[ (literal, pass through)
        let result = telex.processCharacter("[", context: "a")
        XCTAssertNil(result, "Bracket after vowel should be nil (pass through)")
    }

    func testBracketKeyUSpecialCase() {
        let telex = TelexInputMethod()

        // u[ → uơ (special case!)
        let result = telex.processCharacter("[", context: "u")
        XCTAssertNotNil(result)
        if case .standalone(let char) = result?.type {
            XCTAssertEqual(char, "ơ")
        } else {
            XCTFail("Expected standalone ơ for 'u[' special case")
        }
    }

    func testBracketKeyAfterBlocker() {
        let telex = TelexInputMethod()

        // w[ → w[ (literal, after blocker)
        let wResult = telex.processCharacter("[", context: "w")
        XCTAssertNil(wResult, "Bracket after blocker 'w' should be nil")

        // e] → e] (literal, e is blocker AND vowel)
        let eResult = telex.processCharacter("]", context: "e")
        XCTAssertNil(eResult, "Bracket after blocker 'e' should be nil")
    }

    func testBracketKeyAfterDoubleConsonant() {
        let telex = TelexInputMethod()

        // tr[ → trơ (after double consonant)
        let result = telex.processCharacter("[", context: "tr")
        XCTAssertNotNil(result)
        if case .standalone(let char) = result?.type {
            XCTAssertEqual(char, "ơ")
        } else {
            XCTFail("Expected standalone ơ for 'tr['")
        }
    }

    // MARK: - Standalone W Tests (Telex)

    func testStandaloneWAtStart() {
        let telex = TelexInputMethod()

        // w at start → ư (in Telex)
        let result = telex.processCharacter("w", context: "")
        XCTAssertNotNil(result)
        if case .standalone(let char) = result?.type {
            XCTAssertEqual(char, "ư")
        } else {
            XCTFail("Expected standalone ư for 'w' at start in Telex")
        }
    }

    func testStandaloneWAfterConsonant() {
        let telex = TelexInputMethod()

        // bw → bư (in Telex)
        let result = telex.processCharacter("w", context: "b")
        XCTAssertNotNil(result)
        if case .standalone(let char) = result?.type {
            XCTAssertEqual(char, "ư")
        } else {
            XCTFail("Expected standalone ư for 'bw' in Telex")
        }
    }

    // MARK: - Simple Telex Tests

    func testSimpleTelexToneMarks() {
        let simpleTelex = SimpleTelexInputMethod()

        // Same as Telex
        XCTAssertNotNil(simpleTelex.processCharacter("s", context: "a"))
        XCTAssertNotNil(simpleTelex.processCharacter("f", context: "a"))
    }

    func testSimpleTelexCircumflex() {
        let simpleTelex = SimpleTelexInputMethod()

        // aa → â (same as Telex)
        let result = simpleTelex.processCharacter("a", context: "a")
        XCTAssertNotNil(result)
        if case .modifier(.circumflex) = result?.type {
            // Expected
        } else {
            XCTFail("Expected circumflex for 'aa' in Simple Telex")
        }
    }

    func testSimpleTelexOWNoHorn() {
        let simpleTelex = SimpleTelexInputMethod()

        // ow → ow (NO horn in Simple Telex)
        let result = simpleTelex.processCharacter("w", context: "o")
        XCTAssertNil(result, "ow should be nil (pass through) in Simple Telex")
    }

    func testSimpleTelexUWNoHorn() {
        let simpleTelex = SimpleTelexInputMethod()

        // uw → uw (NO horn in Simple Telex)
        let result = simpleTelex.processCharacter("w", context: "u")
        XCTAssertNil(result, "uw should be nil (pass through) in Simple Telex")
    }

    func testSimpleTelexAWBreve() {
        let simpleTelex = SimpleTelexInputMethod()

        // aw → ă (breve WORKS in Simple Telex)
        let result = simpleTelex.processCharacter("w", context: "a")
        XCTAssertNotNil(result)
        if case .modifier(.breve) = result?.type {
            // Expected
        } else {
            XCTFail("Expected breve for 'aw' in Simple Telex")
        }
    }

    func testSimpleTelexStandaloneWNoConversion() {
        let simpleTelex = SimpleTelexInputMethod()

        // w at start → w (NO → ư in Simple Telex)
        let result = simpleTelex.processCharacter("w", context: "")
        XCTAssertNil(result, "Standalone w should be nil (pass through) in Simple Telex")
    }

    func testSimpleTelexBracketWorks() {
        let simpleTelex = SimpleTelexInputMethod()

        // [ at start → ơ (bracket WORKS in Simple Telex)
        let result = simpleTelex.processCharacter("[", context: "")
        XCTAssertNotNil(result)
        if case .standalone(let char) = result?.type {
            XCTAssertEqual(char, "ơ")
        } else {
            XCTFail("Expected standalone ơ for '[' in Simple Telex")
        }
    }

    // MARK: - Input Method Registry Tests

    func testRegistryAvailableIDs() {
        let ids = InputMethodRegistry.availableIDs
        XCTAssertEqual(ids.count, 2)
        XCTAssertTrue(ids.contains("telex"))
        XCTAssertTrue(ids.contains("simple-telex"))
    }

    func testRegistryGetTelex() {
        let method = InputMethodRegistry.get("telex")
        XCTAssertNotNil(method)
        XCTAssertEqual(method?.name, "Telex")
    }

    func testRegistryGetSimpleTelex() {
        let method = InputMethodRegistry.get("simple-telex")
        XCTAssertNotNil(method)
        XCTAssertEqual(method?.name, "Simple Telex")
    }

    func testRegistryDefault() {
        let defaultMethod = InputMethodRegistry.default
        XCTAssertEqual(defaultMethod.name, "Telex")
    }

    func testRegistryGetUnknown() {
        let method = InputMethodRegistry.get("vni")
        XCTAssertNil(method)
    }

    // MARK: - InputMethodState Tests

    func testInputMethodStateInit() {
        let state = InputMethodState()
        XCTAssertNil(state.lastTransformation)
        XCTAssertNil(state.tempDisabledKey)
    }

    func testInputMethodStateDisableKey() {
        var state = InputMethodState()
        state.disableKey("a")
        XCTAssertTrue(state.isDisabled("a"))
        XCTAssertTrue(state.isDisabled("A")) // Case insensitive
        XCTAssertFalse(state.isDisabled("b"))
    }

    func testInputMethodStateReset() {
        var state = InputMethodState()
        state.disableKey("a")
        state.lastTransformation = LastTransformation(type: .circumflex, triggerKey: "a", originalChars: "a")

        state.reset()

        XCTAssertNil(state.lastTransformation)
        XCTAssertNil(state.tempDisabledKey)
    }
}
