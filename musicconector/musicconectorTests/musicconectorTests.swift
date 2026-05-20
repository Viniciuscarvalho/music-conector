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
        let updatedAt = Date(timeIntervalSince1970: 1_777_777_777)
        let artworkURL = URL(string: "https://example.com/artwork.png")
        let releaseDate = Date(timeIntervalSince1970: 1_111_111_111)

        let song = CachedSong(
            id: "apple-music-song-id",
            title: "Get Lucky",
            artistName: "Daft Punk feat. Pharrell Williams",
            artistID: "daft-punk",
            albumTitle: "Random Access Memories",
            albumID: "random-access-memories",
            artworkURL: artworkURL,
            duration: 248,
            releaseDate: releaseDate,
            updatedAt: updatedAt
        )

        #expect(song.id == "apple-music-song-id")
        #expect(song.title == "Get Lucky")
        #expect(song.artistName == "Daft Punk feat. Pharrell Williams")
        #expect(song.artistID == "daft-punk")
        #expect(song.albumTitle == "Random Access Memories")
        #expect(song.albumID == "random-access-memories")
        #expect(song.artworkURL == artworkURL)
        #expect(song.duration == 248)
        #expect(song.releaseDate == releaseDate)
        #expect(song.updatedAt == updatedAt)
    }

    @Test func foundationSchemaCreatesInMemoryContainer() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: CachedAlbum.self,
            CachedSong.self,
            RecentPlay.self,
            configurations: configuration
        )

        #expect(container.configurations.first?.isStoredInMemoryOnly == true)
    }

    @MainActor
    @Test func authorizationStateSupportsUnavailableCases() {
        #expect(MusicAuthorizationState.denied != .authorized)
        #expect(MusicAuthorizationState.restricted != .authorized)
        #expect(MusicAuthorizationState.unknown != .authorized)
    }

}
