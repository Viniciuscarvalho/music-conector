//
//  musicconectorTests.swift
//  musicconectorTests
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation
import SwiftData
import Testing
@testable import musicconector

struct musicconectorTests {

    @Test func cachedSongStoresFoundationMetadata() {
        let playedAt = Date(timeIntervalSince1970: 1_777_777_777)
        let artworkURL = URL(string: "https://example.com/artwork.png")

        let song = CachedSong(
            id: "apple-music-song-id",
            title: "Get Lucky",
            artistName: "Daft Punk feat. Pharrell Williams",
            albumTitle: "Random Access Memories",
            artworkURL: artworkURL,
            lastPlayedAt: playedAt
        )

        #expect(song.id == "apple-music-song-id")
        #expect(song.title == "Get Lucky")
        #expect(song.artistName == "Daft Punk feat. Pharrell Williams")
        #expect(song.albumTitle == "Random Access Memories")
        #expect(song.artworkURL == artworkURL)
        #expect(song.lastPlayedAt == playedAt)
    }

    @Test func foundationSchemaCreatesInMemoryContainer() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: CachedSong.self, configurations: configuration)

        #expect(container.configurations.first?.isStoredInMemoryOnly == true)
    }

    @MainActor
    @Test func authorizationStateSupportsUnavailableCases() {
        #expect(MusicAuthorizationState.denied != .authorized)
        #expect(MusicAuthorizationState.restricted != .authorized)
        #expect(MusicAuthorizationState.unknown != .authorized)
    }

}
