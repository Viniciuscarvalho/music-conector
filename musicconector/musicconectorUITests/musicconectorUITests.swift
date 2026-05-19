//
//  musicconectorUITests.swift
//  musicconectorUITests
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import XCTest

final class musicconectorUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testFoundationScreenLaunches() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Songs"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.searchFields["Search"].exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
