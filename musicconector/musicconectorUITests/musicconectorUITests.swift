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

        XCTAssertTrue(app.staticTexts["MusicConector"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Ready for Apple Music"].exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
