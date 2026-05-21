//
//  RepositoryTests.swift
//  musicconectorTests
//
//  Created by Vinicius Carvalho on 21/05/26.
//

import Foundation
import Testing
@testable import musicconector

@MainActor
struct RepositoryTests {

    @Test func homeRepositoryReadsRecentsAndSearchesThroughDependencies() async throws {
        let catalog = CatalogServiceSpy()
        let store = RecentSongsStoreSpy()
        store.recentSongs = [sampleRepositorySong(id: "recent")]
        catalog.searchResult = PagedResult(
            items: [sampleRepositorySong(id: "result")],
            page: PageRequest(limit: 25, offset: 0),
            nextPage: nil
        )
        let repository = DefaultHomeSongRepository(catalogService: catalog, recentSongsStore: store)

        let recentSongs = try await repository.recentSongs(limit: 1)
        let result = try await repository.searchSongs(term: "daft punk", page: PageRequest())

        #expect(recentSongs.map(\.id) == ["recent"])
        #expect(result.items.map(\.id) == ["result"])
        #expect(store.recentLimits == [1])
        #expect(catalog.searchTerms == ["daft punk"])
    }

    @Test func albumRepositoryLoadsRemoteAlbumAndCachesViewedMetadata() async throws {
        let catalog = CatalogServiceSpy()
        let store = RecentSongsStoreSpy()
        let album = sampleRepositoryAlbum(id: "album")
        catalog.albumResult = album
        store.cachedAlbumResult = album
        let repository = DefaultAlbumRepository(catalogService: catalog, recentSongsStore: store)

        let cachedAlbum = try await repository.cachedAlbum(id: "album")
        let fetchedAlbum = try await repository.fetchAlbum(id: "album")
        try await repository.saveViewedAlbum(album)

        #expect(cachedAlbum?.id == "album")
        #expect(fetchedAlbum.id == "album")
        #expect(catalog.albumIDs == ["album"])
        #expect(store.cachedAlbumIDs == ["album"])
        #expect(store.viewedAlbumIDs == ["album"])
    }

    @Test func playerRepositoryDelegatesPlaybackAndRecentPersistence() async throws {
        let playback = PlaybackManagerSpy()
        let store = RecentSongsStoreSpy()
        let song = sampleRepositorySong(id: "song")
        let repository = DefaultPlayerRepository(playbackManager: playback, recentSongsStore: store)

        let authorization = await repository.requestAuthorization()
        try await repository.play(song: song)
        await repository.pause()
        try await repository.resume()
        try await repository.saveRecentlyPlayed(song)
        let state = try await repository.currentState()

        #expect(authorization == .authorized)
        #expect(state.currentSong?.id == "song")
        #expect(playback.playedSongIDs == ["song", "song"])
        #expect(playback.pauseCallCount == 1)
        #expect(store.savedRecentSongIDs == ["song"])
    }
}

@MainActor
private final class CatalogServiceSpy: MusicCatalogServicing {
    var searchResult = PagedResult<Song>(items: [], page: PageRequest(), nextPage: nil)
    var songResult = sampleRepositorySong(id: "song")
    var albumResult = sampleRepositoryAlbum(id: "album")
    private(set) var searchTerms: [String] = []
    private(set) var songIDs: [Song.ID] = []
    private(set) var albumIDs: [Album.ID] = []

    func searchSongs(term: String, page: PageRequest) async throws -> PagedResult<Song> {
        searchTerms.append(term)
        return searchResult
    }

    func song(id: Song.ID) async throws -> Song {
        songIDs.append(id)
        return songResult
    }

    func album(id: Album.ID) async throws -> Album {
        albumIDs.append(id)
        return albumResult
    }
}

@MainActor
private final class RecentSongsStoreSpy: RecentSongsStoring {
    var recentSongs: [Song] = []
    var cachedAlbumResult: Album?
    private(set) var recentLimits: [Int] = []
    private(set) var savedRecentSongIDs: [Song.ID] = []
    private(set) var viewedSongIDs: [Song.ID] = []
    private(set) var viewedAlbumIDs: [Album.ID] = []
    private(set) var cachedSongIDs: [Song.ID] = []
    private(set) var cachedAlbumIDs: [Album.ID] = []

    func saveRecentlyPlayed(_ song: Song, playedAt: Date) async throws {
        savedRecentSongIDs.append(song.id)
    }

    func saveViewedSong(_ song: Song, viewedAt: Date) async throws {
        viewedSongIDs.append(song.id)
    }

    func saveViewedAlbum(_ album: Album, viewedAt: Date) async throws {
        viewedAlbumIDs.append(album.id)
    }

    func recentlyPlayed(limit: Int) async throws -> [Song] {
        recentLimits.append(limit)
        return Array(recentSongs.prefix(limit))
    }

    func cachedSong(id: Song.ID) async throws -> Song? {
        cachedSongIDs.append(id)
        return recentSongs.first { $0.id == id }
    }

    func cachedAlbum(id: Album.ID) async throws -> Album? {
        cachedAlbumIDs.append(id)
        return cachedAlbumResult
    }
}

@MainActor
private final class PlaybackManagerSpy: MusicPlaybackManaging {
    private(set) var playedSongIDs: [Song.ID] = []
    private(set) var pauseCallCount = 0
    private var state = PlaybackState(authorization: .authorized, availability: .playable)

    func requestAuthorization() async -> MusicAuthorizationState {
        .authorized
    }

    func currentState() async -> PlaybackState {
        state
    }

    func play(song: Song) async throws {
        playedSongIDs.append(song.id)
        state = PlaybackState(
            authorization: .authorized,
            availability: .playable,
            status: .playing,
            currentSong: song,
            elapsedTime: 0,
            duration: song.duration
        )
    }

    func pause() async {
        pauseCallCount += 1
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
        AsyncStream { continuation in
            continuation.yield(state)
            continuation.finish()
        }
    }
}

@MainActor
private func sampleRepositorySong(id: Song.ID) -> Song {
    Song(
        id: id,
        title: "Get Lucky",
        artist: Artist(id: "daft-punk", name: "Daft Punk"),
        albumTitle: "Random Access Memories",
        albumID: "album",
        artworkURL: URL(string: "https://example.com/\(id).jpg"),
        duration: 248
    )
}

@MainActor
private func sampleRepositoryAlbum(id: Album.ID) -> Album {
    Album(
        id: id,
        title: "Random Access Memories",
        artist: Artist(id: "daft-punk", name: "Daft Punk"),
        artworkURL: URL(string: "https://example.com/\(id).jpg"),
        tracks: [sampleRepositorySong(id: "track")]
    )
}
