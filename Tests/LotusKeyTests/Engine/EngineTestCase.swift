// swiftlint:disable final_test_case
@testable import LotusKey
import XCTest

/// Base test class providing common setup for Vietnamese engine tests
class EngineTestCase: XCTestCase {
    // swiftlint:disable:next implicitly_unwrapped_optional
    var engine: DefaultVietnameseEngine!

    override func setUp() {
        super.setUp()
        engine = DefaultVietnameseEngine()
    }

    override func tearDown() {
        engine = nil
        super.tearDown()
    }
}

// swiftlint:enable final_test_case
