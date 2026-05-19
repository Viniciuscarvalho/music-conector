//
//  DesignSystemTests.swift
//  musicconectorTests
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation
import Testing
@testable import musicconector

struct DesignSystemTests {

    @MainActor
    @Test func spacingTokensUseCompactPositiveScale() {
        #expect(MCSpacing.xxSmall > 0)
        #expect(MCSpacing.xxSmall < MCSpacing.small)
        #expect(MCSpacing.small < MCSpacing.large)
        #expect(MCSpacing.screenHorizontal >= MCSpacing.large)
    }

    @MainActor
    @Test func artworkTokensMatchScreenshotHierarchy() {
        #expect(MCArtworkSize.row < MCArtworkSize.albumHeader)
        #expect(MCArtworkSize.albumHeader < MCArtworkSize.player)
        #expect(MCRadius.artwork < MCRadius.largeArtwork)
    }

    @MainActor
    @Test func controlTokensKeepTapTargetsUsable() {
        #expect(MCControlSize.navigationButton >= 44)
        #expect(MCControlSize.playerPrimaryButton > MCControlSize.playerSecondaryButton)
        #expect(MCControlSize.searchHeight >= 36)
    }

    @MainActor
    @Test func songRowContentCarriesDisplayMetadata() {
        let artworkURL = URL(string: "https://example.com/artwork.png")
        let content = MCSongRowContent(
            id: "song-id",
            title: "Get Lucky",
            subtitle: "Daft Punk feat. Pharrell Williams",
            artworkURL: artworkURL
        )

        #expect(content.id == "song-id")
        #expect(content.title == "Get Lucky")
        #expect(content.subtitle == "Daft Punk feat. Pharrell Williams")
        #expect(content.artworkURL == artworkURL)
    }
}
