//
//  PlayerRepository.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation

@MainActor
protocol PlayerRepository {
    func requestAuthorization() async -> MusicAuthorizationState
    func currentState() async -> PlaybackState
    func play(song: Song) async throws
    func pause() async
    func resume() async throws
    func progressUpdates(every interval: Duration) -> AsyncStream<PlaybackState>
    func saveRecentlyPlayed(_ song: Song) async throws
}

@MainActor
final class DefaultPlayerRepository: PlayerRepository {
    private let playbackManager: MusicPlaybackManaging
    private let recentSongsStore: RecentSongsStoring

    init(playbackManager: MusicPlaybackManaging, recentSongsStore: RecentSongsStoring) {
        self.playbackManager = playbackManager
        self.recentSongsStore = recentSongsStore
    }

    func requestAuthorization() async -> MusicAuthorizationState {
        await playbackManager.requestAuthorization()
    }

    func currentState() async -> PlaybackState {
        await playbackManager.currentState()
    }

    func play(song: Song) async throws {
        try await playbackManager.play(song: song)
    }

    func pause() async {
        await playbackManager.pause()
    }

    func resume() async throws {
        try await playbackManager.resume()
    }

    func progressUpdates(every interval: Duration) -> AsyncStream<PlaybackState> {
        playbackManager.progressUpdates(every: interval)
    }

    func saveRecentlyPlayed(_ song: Song) async throws {
        try await recentSongsStore.saveRecentlyPlayed(song, playedAt: .now)
    }
}
