//
//  MusicKitPlaybackManager.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation
// ApplicationMusicPlayer stays behind this @MainActor adapter. The import bridges
// MusicKit playback APIs that are not fully Sendable-annotated yet.
@preconcurrency import MusicKit

@MainActor
final class MusicKitPlaybackManager: MusicPlaybackManaging {
    private let authorizationProvider: MusicAuthorizationProviding
    private let player: ApplicationMusicPlayer
    private var currentDomainSong: Song?

    init(
        authorizationProvider: MusicAuthorizationProviding = MusicKitAuthorizationProvider(),
        player: ApplicationMusicPlayer = .shared
    ) {
        self.authorizationProvider = authorizationProvider
        self.player = player
    }

    func requestAuthorization() async -> MusicAuthorizationState {
        await authorizationProvider.requestAuthorization()
    }

    func currentState() async -> PlaybackState {
        let authorization = await authorizationProvider.currentStatus()
        return PlaybackState(
            authorization: authorization,
            availability: await availability(for: authorization),
            status: PlaybackStatus(musicKitStatus: player.state.playbackStatus),
            currentSong: currentDomainSong,
            elapsedTime: player.playbackTime,
            duration: currentDomainSong?.duration
        )
    }

    func play(song: Song) async throws {
        let authorization = await authorizationProvider.currentStatus()
        switch authorization {
        case .authorized:
            break
        case .denied:
            throw MusicPlaybackError.authorizationDenied
        case .restricted:
            throw MusicPlaybackError.authorizationRestricted
        case .notDetermined, .unknown:
            let requested = await authorizationProvider.requestAuthorization()
            guard requested == .authorized else {
                throw MusicPlaybackError.authorizationDenied
            }
        }

        switch await catalogPlaybackAvailability() {
        case .playable:
            break
        case .subscriptionRequired:
            throw MusicPlaybackError.subscriptionRequired
        case .unavailable(let message):
            throw MusicPlaybackError.playbackUnavailable(message)
        case .unknown, .authorizationRequired:
            throw MusicPlaybackError.playbackUnavailable(Self.playbackVerificationMessage)
        }

        let catalogSong = try await musicKitSong(id: song.id)
        player.queue = ApplicationMusicPlayer.Queue(for: [catalogSong], startingAt: catalogSong)
        try await player.play()
        currentDomainSong = song
    }

    func pause() async {
        player.pause()
    }

    func resume() async throws {
        try await player.play()
    }

    func progressUpdates(every interval: Duration = .seconds(1)) -> AsyncStream<PlaybackState> {
        AsyncStream { continuation in
            let task = Task {
                while !Task.isCancelled {
                    continuation.yield(await currentState())
                    try? await Task.sleep(for: interval)
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    private func availability(for authorization: MusicAuthorizationState) async -> PlaybackAvailability {
        switch authorization {
        case .authorized:
            await catalogPlaybackAvailability()
        case .notDetermined:
            .authorizationRequired
        case .denied:
            .unavailable("Apple Music access was denied.")
        case .restricted:
            .unavailable("Apple Music access is restricted on this device.")
        case .unknown:
            .unknown
        }
    }

    private func catalogPlaybackAvailability() async -> PlaybackAvailability {
        do {
            let subscription = try await MusicSubscription.current
            return subscription.canPlayCatalogContent ? .playable : .subscriptionRequired
        } catch {
            return .unavailable(Self.playbackVerificationMessage)
        }
    }

    private static let playbackVerificationMessage = "Apple Music playback could not be verified. Open the Music app, confirm your subscription, then try again."

    private func musicKitSong(id: Song.ID) async throws -> MusicKit.Song {
        var request = MusicCatalogResourceRequest<MusicKit.Song>(
            matching: \.id,
            equalTo: MusicItemID(id)
        )
        request.limit = 1

        let response = try await request.response()
        guard let song = response.items.first else {
            throw MusicPlaybackError.songUnavailable(id)
        }

        return song
    }
}
