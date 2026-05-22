//
//  UITestDependencies.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 21/05/26.
//

import SwiftData
import SwiftUI

private enum UITestEnvironment {
    static var isEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("-ui-testing")
    }

    static var usesUnavailablePlayback: Bool {
        ProcessInfo.processInfo.environment["MUSICCONNECTOR_UI_TEST_PLAYBACK_UNAVAILABLE"] == "1"
    }
}

extension View {
    @ViewBuilder
    func musicConectorUITestDependenciesIfNeeded() -> some View {
        if UITestEnvironment.isEnabled {
            self
                .environment(\.homeDependencies, HomeDependencies.uiTest)
                .environment(\.albumDependencies, AlbumDependencies.uiTest)
                .environment(\.playerDependencies, PlayerDependencies.uiTest)
        } else {
            self
        }
    }
}

private extension HomeDependencies {
    static let uiTest = HomeDependencies { _ in
        UITestHomeSongRepository()
    }
}

private extension AlbumDependencies {
    static let uiTest = AlbumDependencies { _ in
        UITestAlbumRepository()
    }
}

private extension PlayerDependencies {
    static let uiTest = PlayerDependencies { _ in
        UITestPlayerRepository(isPlaybackUnavailable: UITestEnvironment.usesUnavailablePlayback)
    }
}

@MainActor
private final class UITestHomeSongRepository: HomeSongRepository {
    func recentSongs(limit: Int) async throws -> [Song] {
        Array(Self.songs.prefix(limit))
    }

    func searchSongs(term: String, page: PageRequest, policy: HomeSearchPolicy) async throws -> PagedResult<Song> {
        PagedResult(items: Self.songs, page: page, nextPage: nil)
    }

    func albumID(for song: Song) async throws -> Album.ID {
        song.resolvedAlbumID ?? Self.album.id
    }

    private static let songs = [
        Song(
            id: "ui-get-lucky",
            title: "Get Lucky",
            artist: Artist(id: "daft-punk", name: "Daft Punk feat. Pharrell Williams"),
            albumTitle: "Random Access Memories",
            albumID: "ui-random-access-memories",
            duration: 240
        ),
        Song(
            id: "ui-around-the-world",
            title: "Around the World",
            artist: Artist(id: "daft-punk", name: "Daft Punk"),
            albumTitle: "Homework",
            albumID: "ui-homework",
            duration: 250
        )
    ]

    private static let album = Album(
        id: "ui-random-access-memories",
        title: "Random Access Memories",
        artist: Artist(id: "daft-punk", name: "Daft Punk")
    )
}

@MainActor
private final class UITestAlbumRepository: AlbumRepository {
    func cachedAlbum(id: Album.ID) async throws -> Album? {
        nil
    }

    func fetchAlbum(id: Album.ID) async throws -> Album {
        Album(
            id: id,
            title: "Random Access Memories",
            artist: Artist(id: "daft-punk", name: "Daft Punk"),
            tracks: [
                Song(
                    id: "ui-get-lucky",
                    title: "Get Lucky",
                    artist: Artist(id: "daft-punk", name: "Daft Punk feat. Pharrell Williams"),
                    albumTitle: "Random Access Memories",
                    albumID: id,
                    duration: 240
                ),
                Song(
                    id: "ui-contact",
                    title: "Contact",
                    artist: Artist(id: "daft-punk", name: "Daft Punk"),
                    albumTitle: "Random Access Memories",
                    albumID: id,
                    duration: 260
                )
            ]
        )
    }

    func saveViewedAlbum(_ album: Album) async throws {}
}

@MainActor
private final class UITestPlayerRepository: PlayerRepository {
    private let isPlaybackUnavailable: Bool
    private var state: PlaybackState

    init(isPlaybackUnavailable: Bool) {
        self.isPlaybackUnavailable = isPlaybackUnavailable
        self.state = PlaybackState(
            authorization: .authorized,
            availability: isPlaybackUnavailable ? .subscriptionRequired : .playable,
            status: .paused,
            elapsedTime: 86,
            duration: 240
        )
    }

    func requestAuthorization() async -> MusicAuthorizationState {
        .authorized
    }

    func currentState() async throws -> PlaybackState {
        state
    }

    func play(song: Song) async throws {
        guard !isPlaybackUnavailable else {
            throw MusicPlaybackError.subscriptionRequired
        }

        state = PlaybackState(
            authorization: .authorized,
            availability: .playable,
            status: .playing,
            currentSong: song,
            elapsedTime: 96,
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
        let state = state
        return AsyncStream { continuation in
            continuation.yield(state)
            continuation.finish()
        }
    }

    func saveRecentlyPlayed(_ song: Song) async throws {}
}
