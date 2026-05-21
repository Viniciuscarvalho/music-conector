//
//  HomeAdaptiveLayoutTests.swift
//  musicconectorTests
//
//  Created by Vinicius Carvalho on 21/05/26.
//

import SwiftUI
import Testing
@testable import musicconector

@MainActor
struct HomeAdaptiveLayoutTests {

    @Test func regularWidthUsesSplitLayoutForIPadPortraitClass() {
        let layout = HomeAdaptiveLayout(horizontalSizeClass: .regular, verticalSizeClass: .regular)

        #expect(layout.usesSplitLayout)
        #expect(layout.sidebar.minimumWidth == 340)
        #expect(layout.sidebar.idealWidth == 420)
        #expect(layout.sidebar.maximumWidth == 500)
    }

    @Test func regularWidthUsesSplitLayoutForIPadLandscapeClass() {
        let layout = HomeAdaptiveLayout(horizontalSizeClass: .regular, verticalSizeClass: .compact)

        #expect(layout.usesSplitLayout)
        #expect(layout.sidebar.minimumWidth == 320)
        #expect(layout.sidebar.idealWidth == 380)
        #expect(layout.sidebar.maximumWidth == 440)
    }

    @Test func compactWidthKeepsStackedPhoneNavigation() {
        let layout = HomeAdaptiveLayout(horizontalSizeClass: .compact, verticalSizeClass: .regular)

        #expect(!layout.usesSplitLayout)
    }
}
