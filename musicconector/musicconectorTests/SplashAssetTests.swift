//
//  SplashAssetTests.swift
//  musicconectorTests
//
//  Created by Vinicius Carvalho on 21/05/26.
//

import SwiftUI
import Testing
@testable import musicconector

@MainActor
struct SplashAssetTests {

    @Test func compactWidthUsesPhoneSplash() {
        let asset = SplashAsset(horizontalSizeClass: .compact)

        #expect(asset == .phone)
        #expect(asset.rawValue == "Splash")
    }

    @Test func regularWidthUsesPadSplash() {
        let asset = SplashAsset(horizontalSizeClass: .regular)

        #expect(asset == .pad)
        #expect(asset.rawValue == "Splash-iPad")
    }

    @Test func nilSizeClassFallsBackToPhoneSplash() {
        let asset = SplashAsset(horizontalSizeClass: nil)

        #expect(asset == .phone)
    }
}
