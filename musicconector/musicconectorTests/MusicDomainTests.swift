//
//  MusicDomainTests.swift
//  musicconectorTests
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation
import SwiftData
import Testing
@testable import musicconector

@MainActor
struct MusicDomainTests {

    @Test func pageRequestClampsValuesAndAdvancesOffset() {
        let page = PageRequest(limit: 100, offset: -20)

        #expect(page.limit == 25)
        #expect(page.offset == 0)
        #expect(page.next.offset == 25)
    }

    @Test func pagedResultCarriesNextPage() {
        let page = PageRequest(limit: 2, offset: 0)
        let nextPage = page.next
        let result = PagedResult(
            items: [sampleSong(id: "1"), sampleSong(id: "2")],
            page: page,
            nextPage: nextPage
        )

        #expect(result.items.map(\.id) == ["1", "2"])
        #expect(result.nextPage?.offset == 2)
    }

    @Test func catalogServiceProtocolSupportsPaginationMocks() async throws {
        let service = MockCatalogService()
        let firstPage = PageRequest(limit: 2, offset: 0)
        let result = try await service.searchSongs(term: "daft punk", page: firstPage)

        #expect(service.receivedSearchTerms == ["daft punk"])
        #expect(result.items.count == 2)
        #expect(result.nextPage == firstPage.next)
    }

    @Test func playbackManagerProtocolExposesAuthorizationAndProgressMocks() async throws {
        let manager = MockPlaybackManager()
        let authorization = await manager.requestAuthorization()

        #expect(authorization == .authorized)

        try await manager.play(song: sampleSong(id: "playable"))
        let state = await manager.currentState()

        #expect(state.status == .playing)
        #expect(state.currentSong?.id == "playable")

        var progressIterator = manager.progressUpdates(every: .milliseconds(10)).makeAsyncIterator()
        let progress = await progressIterator.next()

        #expect(progress?.status == .playing)
        #expect(progress?.currentSong?.id == "playable")
    }

    @Test func recentSongsStorePersistsAndOrdersRecentSongsInMemory() async throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: CachedSong.self, configurations: configuration)
        let context = ModelContext(container)
        let store = SwiftDataRecentSongsStore(modelContext: context)

        try await store.saveRecentlyPlayed(sampleSong(id: "older", title: "Older"), playedAt: Date(timeIntervalSince1970: 10))
        try await store.saveRecentlyPlayed(sampleSong(id: "newer", title: "Newer"), playedAt: Date(timeIntervalSince1970: 20))
        try await store.saveRecentlyPlayed(sampleSong(id: "older", title: "Older Updated"), playedAt: Date(timeIntervalSince1970: 30))

        let recentSongs = try await store.recentlyPlayed(limit: 2)

        #expect(recentSongs.map(\.id) == ["older", "newer"])
        #expect(recentSongs.first?.title == "Older Updated")
    }
}

@MainActor
private final class MockCatalogService: MusicCatalogServicing {
    private(set) var receivedSearchTerms: [String] = []

    func searchSongs(term: String, page: PageRequest) async throws -> PagedResult<Song> {
        receivedSearchTerms.append(term)
        let songs = [
            sampleSong(id: "\(page.offset + 1)"),
            sampleSong(id: "\(page.offset + 2)")
        ]

        return PagedResult(items: songs, page: page, nextPage: page.next)
    }

    func song(id: Song.ID) async throws -> Song {
        sampleSong(id: id)
    }
}

@MainActor
private final class MockPlaybackManager: MusicPlaybackManaging {
    private var state = PlaybackState(authorization: .authorized, availability: .playable)

    func requestAuthorization() async -> MusicAuthorizationState {
        .authorized
    }

    func currentState() async -> PlaybackState {
        state
    }

    func play(song: Song) async throws {
        state = PlaybackState(
            authorization: .authorized,
            availability: .playable,
            status: .playing,
            currentSong: song,
            elapsedTime: 12,
            duration: song.duration
        )
    }

    func pause() async {
        state = PlaybackState(
            authorization: state.authorization,
            availability: state.availability,
            status: .paused,
            currentSong: state.currentSong,
            elapsedTime: state.elapsedTime,
            duration: state.duration
        )
    }

    func resume() async throws {
        guard let song = state.currentSong else { return }
        try await play(song: song)
    }

    func progressUpdates(every interval: Duration) -> AsyncStream<PlaybackState> {
        let currentState = state

        return AsyncStream { continuation in
            continuation.yield(currentState)
            continuation.finish()
        }
    }
}

@MainActor
private func sampleSong(id: String, title: String = "Get Lucky") -> Song {
    Song(
        id: id,
        title: title,
        artist: Artist(id: "daft-punk", name: "Daft Punk"),
        albumTitle: "Random Access Memories",
        artworkURL: URL(string: "https://example.com/\(id).jpg"),
        duration: 248
    )
}
