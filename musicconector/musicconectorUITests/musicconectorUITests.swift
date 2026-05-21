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
        let app = launchApp()

        XCTAssertTrue(app.staticTexts["Songs"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.searchFields["Search"].exists)
    }

    @MainActor
    func testPlayerShowsArtworkProgressAndPlayPauseControls() throws {
        let app = launchApp()

        XCTAssertTrue(app.buttons["song-row-ui-get-lucky"].waitForExistence(timeout: 5))
        app.buttons["song-row-ui-get-lucky"].tap()

        XCTAssertTrue(app.otherElements["player-screen"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.images["artwork"].exists || app.otherElements["artwork"].exists)
        XCTAssertTrue(app.otherElements["player-progress"].exists)
        XCTAssertTrue(app.otherElements["player-controls"].exists)

        let playPauseButton = app.buttons["player-play-pause-button"]
        XCTAssertTrue(playPauseButton.exists)
        XCTAssertEqual(playPauseButton.label, "Play")

        playPauseButton.tap()
        XCTAssertTrue(app.buttons["Pause"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testPlaybackUnavailableShowsFinalVisualState() throws {
        let app = launchApp(environment: ["MUSICCONNECTOR_UI_TEST_PLAYBACK_UNAVAILABLE": "1"])

        XCTAssertTrue(app.buttons["song-row-ui-get-lucky"].waitForExistence(timeout: 5))
        app.buttons["song-row-ui-get-lucky"].tap()

        XCTAssertTrue(app.staticTexts["Apple Music playback is unavailable for this account."].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["player-play-pause-button"].isEnabled)
    }

    @MainActor
    func testMoreOptionsSheetNavigatesToAlbumScreen() throws {
        let app = launchApp()

        XCTAssertTrue(app.buttons["song-more-ui-get-lucky"].waitForExistence(timeout: 5))
        app.buttons["song-more-ui-get-lucky"].tap()

        XCTAssertTrue(app.otherElements["more-options-sheet"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Get Lucky"].exists)
        XCTAssertTrue(app.buttons["View album"].exists)

        app.buttons["View album"].tap()

        XCTAssertTrue(app.otherElements["album-screen"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Random Access Memories"].exists)
        XCTAssertTrue(app.buttons["song-row-ui-contact"].exists)
    }

    @MainActor
    func testPlayerMoreOptionsSheetNavigatesToAlbumScreen() throws {
        let app = launchApp()

        XCTAssertTrue(app.buttons["song-row-ui-get-lucky"].waitForExistence(timeout: 5))
        app.buttons["song-row-ui-get-lucky"].tap()

        XCTAssertTrue(app.otherElements["player-screen"].waitForExistence(timeout: 5))
        app.buttons["More options"].tap()

        XCTAssertTrue(app.otherElements["more-options-sheet"].waitForExistence(timeout: 5))
        app.buttons["View album"].tap()

        XCTAssertTrue(app.otherElements["album-screen"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Random Access Memories"].exists)
    }

    @MainActor
    func testPlayerSupportsSwipeBackGesture() throws {
        let app = launchApp()

        XCTAssertTrue(app.buttons["song-row-ui-get-lucky"].waitForExistence(timeout: 5))
        app.buttons["song-row-ui-get-lucky"].tap()

        XCTAssertTrue(app.otherElements["player-screen"].waitForExistence(timeout: 5))
        app.otherElements["player-screen"].swipeRight()

        XCTAssertTrue(app.searchFields["Search"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testAlbumSupportsSwipeBackGesture() throws {
        let app = launchApp()

        XCTAssertTrue(app.buttons["song-more-ui-get-lucky"].waitForExistence(timeout: 5))
        app.buttons["song-more-ui-get-lucky"].tap()
        XCTAssertTrue(app.otherElements["more-options-sheet"].waitForExistence(timeout: 5))
        app.buttons["View album"].tap()

        XCTAssertTrue(app.otherElements["album-screen"].waitForExistence(timeout: 5))
        app.otherElements["album-screen"].swipeRight()

        XCTAssertTrue(app.searchFields["Search"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            _ = launchApp()
        }
    }

    @MainActor
    private func launchApp(environment: [String: String] = [:]) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append("-ui-testing")
        environment.forEach { key, value in
            app.launchEnvironment[key] = value
        }
        app.launch()
        return app
    }
}
