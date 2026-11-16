import XCTest
@testable import LSS

final class RecordURLParserTests: XCTestCase {
    private let parser = RecordURLParser()

    func testParsesDefaultFoodShortcutRecord() throws {
        let url = try XCTUnwrap(URL(string: "lss://record?amount=12.5"))

        let request = try parser.parse(url).get()

        XCTAssertEqual(request.amount, try XCTUnwrap(Decimal(string: "12.5")))
        XCTAssertEqual(request.category, .food)
        XCTAssertEqual(request.source, .shortcut)
    }

    func testParsesDailyCategory() throws {
        let url = try XCTUnwrap(URL(string: "lss://record?amount=8&category=daily"))

        let request = try parser.parse(url).get()

        XCTAssertEqual(request.amount, Decimal(8))
        XCTAssertEqual(request.category, .daily)
    }

    func testInvalidCategoryFallsBackToFood() throws {
        let url = try XCTUnwrap(URL(string: "lss://record?amount=9&category=bad"))

        let request = try parser.parse(url).get()

        XCTAssertEqual(request.category, .food)
    }

    func testMissingAmountFails() throws {
        let url = try XCTUnwrap(URL(string: "lss://record"))

        XCTAssertEqual(parser.parse(url), .failure(.missingAmount))
    }

    func testInvalidAmountFails() throws {
        let url = try XCTUnwrap(URL(string: "lss://record?amount=abc"))

        XCTAssertEqual(parser.parse(url), .failure(.invalidAmount))
    }

    func testZeroAmountFails() throws {
        let url = try XCTUnwrap(URL(string: "lss://record?amount=0"))

        XCTAssertEqual(parser.parse(url), .failure(.nonPositiveAmount))
    }
}
