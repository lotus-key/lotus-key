// swiftlint:disable final_test_case
@testable import LotusKey
import XCTest

/// Base test case for TypingBuffer tests
class TypingBufferTestCase: XCTestCase {
    // swiftlint:disable:next implicitly_unwrapped_optional
    var buffer: TypingBuffer!

    override func setUp() {
        super.setUp()
        buffer = TypingBuffer()
    }

    override func tearDown() {
        buffer = nil
        super.tearDown()
    }
}

// swiftlint:enable final_test_case
