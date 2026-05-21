//
//  musicconectorUITestsLaunchTests.swift
//  musicconectorUITests
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import XCTest

final class musicconectorUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-ui-testing")
        app.launch()

        XCTAssertTrue(app.staticTexts["Songs"].waitForExistence(timeout: 5))

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "MusicConector Design System"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
