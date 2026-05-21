//
//  PlayerViewModelTests.swift
//  musicconectorTests
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation
import Testing
@testable import musicconector

@MainActor
struct PlayerViewModelTests {

    @Test func playStartsPlaybackAndSavesRecentlyPlayedSong() async {
        let song = samplePlayerSong()
        let repository = PlayerRepositoryFake()
        let viewModel = PlayerViewModel(song: song, repository: repository)

        await viewModel.playPauseTapped()

        #expect(viewModel.isPlaying)
        #expect(viewModel.playbackState.currentSong?.id == song.id)
        #expect(repository.playedSongIDs == [song.id])
        #expect(repository.savedRecentSongIDs == [song.id])
    }

    @Test func pauseStopsActivePlayback() async {
        let song = samplePlayerSong()
        let repository = PlayerRepositoryFake()
        repository.state = PlaybackState(
            authorization: .authorized,
            availability: .playable,
            status: .playing,
            currentSong: song,
            elapsedTime: 24,
            duration: song.duration
        )
        let viewModel = PlayerViewModel(song: song, repository: repository)
        await viewModel.load()

        await viewModel.playPauseTapped()

        #expect(!viewModel.isPlaying)
        #expect(repository.pauseCallCount == 1)
        #expect(viewModel.playbackState.status == .paused)
    }

    @Test func progressUpdatesRefreshElapsedTime() async throws {
        let song = samplePlayerSong()
        let repository = PlayerRepositoryFake()
        repository.progressStates = [
            PlaybackState(
                authorization: .authorized,
                availability: .playable,
                status: .playing,
                currentSong: song,
                elapsedTime: 42,
                duration: song.duration
            )
        ]
        let viewModel = PlayerViewModel(song: song, repository: repository)

        viewModel.startProgressUpdates()
        try await Task.sleep(for: .milliseconds(20))

        #expect(viewModel.elapsedTime == 42)
        #expect(viewModel.progress == 0.175)
    }

    @Test func authorizationDeniedShowsDisabledFallbackState() async {
        let song = samplePlayerSong()
        let repository = PlayerRepositoryFake()
        repository.playError = MusicPlaybackError.authorizationDenied
        let viewModel = PlayerViewModel(song: song, repository: repository)

        await viewModel.playPauseTapped()

        #expect(!viewModel.isPlaying)
        #expect(viewModel.isPlaybackDisabled)
        #expect(viewModel.message == "Apple Music access was denied.")
        #expect(repository.savedRecentSongIDs.isEmpty)
    }

    @Test func playbackVerificationFailureShowsActionableFallbackState() async {
        let song = samplePlayerSong()
        let repository = PlayerRepositoryFake()
        repository.playError = MusicPlaybackError.playbackUnavailable(
            "Apple Music playback could not be verified. Open the Music app, confirm your subscription, then try again."
        )
        let viewModel = PlayerViewModel(song: song, repository: repository)

        await viewModel.playPauseTapped()

        #expect(!viewModel.isPlaying)
        #expect(viewModel.isPlaybackDisabled)
        #expect(viewModel.message == "Apple Music playback could not be verified. Open the Music app, confirm your subscription, then try again.")
        #expect(repository.savedRecentSongIDs.isEmpty)
    }

    @Test func recentPersistenceFailureDoesNotBlockPlayback() async {
        let song = samplePlayerSong()
        let repository = PlayerRepositoryFake()
        repository.saveRecentError = MusicPlaybackError.songUnavailable(song.id)
        let viewModel = PlayerViewModel(song: song, repository: repository)

        await viewModel.playPauseTapped()

        #expect(viewModel.isPlaying)
        #expect(viewModel.message == "Playback started, but this song could not be saved to recent songs.")
    }

    @Test func loadShowsAvailabilityMessageWithoutBlockingMetadata() async {
        let song = samplePlayerSong()
        let repository = PlayerRepositoryFake()
        repository.state = PlaybackState(
            authorization: .denied,
            availability: .unavailable("Apple Music access was denied."),
            currentSong: nil,
            duration: nil
        )
        let viewModel = PlayerViewModel(song: song, repository: repository)

        await viewModel.load()

        #expect(viewModel.playbackState.currentSong?.id == song.id)
        #expect(viewModel.duration == song.duration)
        #expect(viewModel.state == .ready)
        #expect(viewModel.message == "Apple Music access was denied.")
    }

    @Test func loadFailureShowsRetryableErrorState() async {
        let song = samplePlayerSong()
        let repository = PlayerRepositoryFake()
        repository.currentStateError = URLError(.notConnectedToInternet)
        let viewModel = PlayerViewModel(song: song, repository: repository)

        await viewModel.load()

        #expect(viewModel.state == .error("Check your internet connection and try again."))
        #expect(viewModel.message == nil)
    }

    @Test func invalidSongMetadataShowsPlayerErrorState() async {
        let song = Song(
            id: "broken-song",
            title: " ",
            artist: Artist(id: "artist", name: "Daft Punk"),
            duration: 240
        )
        let repository = PlayerRepositoryFake()
        let viewModel = PlayerViewModel(song: song, repository: repository)

        await viewModel.load()

        #expect(viewModel.state == .error("This song has incomplete metadata and cannot be displayed."))
        #expect(repository.currentStateCallCount == 0)
    }
}

@MainActor
private final class PlayerRepositoryFake: PlayerRepository {
    var state = PlaybackState(
        authorization: .authorized,
        availability: .playable,
        status: .stopped
    )
    var currentStateError: Error?
    var playError: Error?
    var saveRecentError: Error?
    var progressStates: [PlaybackState] = []
    private(set) var playedSongIDs: [Song.ID] = []
    private(set) var savedRecentSongIDs: [Song.ID] = []
    private(set) var pauseCallCount = 0
    private(set) var currentStateCallCount = 0

    func requestAuthorization() async -> MusicAuthorizationState {
        state.authorization
    }

    func currentState() async throws -> PlaybackState {
        currentStateCallCount += 1
        if let currentStateError {
            throw currentStateError
        }

        return state
    }

    func play(song: Song) async throws {
        if let playError {
            throw playError
        }

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
        let states = progressStates

        return AsyncStream { continuation in
            for state in states {
                continuation.yield(state)
            }
            continuation.finish()
        }
    }

    func saveRecentlyPlayed(_ song: Song) async throws {
        if let saveRecentError {
            throw saveRecentError
        }

        savedRecentSongIDs.append(song.id)
    }
}

@MainActor
private func samplePlayerSong() -> Song {
    Song(
        id: "get-lucky",
        title: "Get Lucky",
        artist: Artist(id: "daft-punk", name: "Daft Punk feat. Pharrell Williams"),
        albumTitle: "Random Access Memories",
        albumID: "ram",
        artworkURL: URL(string: "https://example.com/get-lucky.jpg"),
        duration: 240
    )
}
