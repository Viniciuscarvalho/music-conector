//
//  PlayerViewModel.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class PlayerViewModel {
    enum State: Equatable {
        case loading
        case ready
        case error(String)
    }

    private(set) var state: State = .loading
    private(set) var playbackState: PlaybackState
    private(set) var message: String?

    let songID: Song.ID
    private let song: Song
    private let repository: any PlayerRepository
    @ObservationIgnored private var progressTask: Task<Void, Never>?

    init(song: Song, repository: any PlayerRepository) {
        self.songID = song.id
        self.song = song
        self.repository = repository
        self.playbackState = PlaybackState(
            authorization: .unknown,
            availability: .unknown,
            currentSong: song,
            duration: song.duration
        )
    }

    deinit {
        progressTask?.cancel()
    }

    var isPlaying: Bool {
        playbackState.currentSong?.id == song.id && playbackState.status == .playing
    }

    var isPlaybackDisabled: Bool {
        switch playbackState.availability {
        case .unavailable, .subscriptionRequired:
            true
        case .unknown, .playable, .authorizationRequired:
            false
        }
    }

    var elapsedTime: TimeInterval {
        max(0, playbackState.elapsedTime)
    }

    var duration: TimeInterval {
        max(0, playbackState.duration ?? song.duration ?? 0)
    }

    var progress: Double {
        guard duration > 0 else { return 0 }
        return min(1, max(0, elapsedTime / duration))
    }

    func load() async {
        state = .loading
        message = nil

        guard song.hasRequiredDisplayMetadata else {
            state = .error("This song has incomplete metadata and cannot be displayed.")
            return
        }

        do {
            playbackState = try await repository.currentState().displaying(song: song)
            message = playbackState.availability.displayMessage
            state = .ready
        } catch {
            state = .error(Self.message(forLoadError: error))
        }
    }

    func playPauseTapped() async {
        message = nil

        do {
            let persistenceMessage: String?
            if isPlaying {
                await repository.pause()
                playbackState = try await repository.currentState().displaying(song: song)
                persistenceMessage = nil
            } else if playbackState.currentSong?.id == song.id, playbackState.status == .paused {
                try await repository.resume()
                persistenceMessage = await markRecentlyPlayed()
            } else {
                try await repository.play(song: song)
                persistenceMessage = await markRecentlyPlayed()
            }

            playbackState = try await repository.currentState().displaying(song: song)
            message = persistenceMessage ?? playbackState.availability.displayMessage
            state = .ready
            startProgressUpdates()
        } catch {
            playbackState = playbackState.withAvailability(error.playbackAvailability)
            message = error.playbackMessage
        }
    }

    func startProgressUpdates() {
        progressTask?.cancel()
        progressTask = Task { [repository, song] in
            for await state in repository.progressUpdates(every: .seconds(1)) {
                guard !Task.isCancelled else { return }
                playbackState = state.displaying(song: song)
                message = playbackState.availability.displayMessage
            }
        }
    }

    func stopProgressUpdates() {
        progressTask?.cancel()
        progressTask = nil
    }

    private func markRecentlyPlayed() async -> String? {
        do {
            try await repository.saveRecentlyPlayed(song)
            return nil
        } catch {
            return "Playback started, but this song could not be saved to recent songs."
        }
    }

    private static func message(forLoadError error: Error) -> String {
        if error.isConnectionUnavailable {
            return "Check your internet connection and try again."
        }

        if case MusicCatalogError.invalidCatalogData = error {
            return "This song has incomplete metadata and cannot be displayed."
        }

        return "Player could not be loaded. Try again."
    }
}

private extension Song {
    var hasRequiredDisplayMetadata: Bool {
        !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !artist.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

private extension PlaybackState {
    func displaying(song: Song) -> PlaybackState {
        PlaybackState(
            authorization: authorization,
            availability: availability,
            status: status,
            currentSong: currentSong ?? song,
            elapsedTime: elapsedTime,
            duration: duration ?? song.duration
        )
    }

    func withAvailability(_ availability: PlaybackAvailability) -> PlaybackState {
        PlaybackState(
            authorization: authorization,
            availability: availability,
            status: status,
            currentSong: currentSong,
            elapsedTime: elapsedTime,
            duration: duration
        )
    }
}

private extension PlaybackAvailability {
    var displayMessage: String? {
        switch self {
        case .authorizationRequired:
            "Apple Music access is required to play full songs."
        case .subscriptionRequired:
            "Apple Music playback is unavailable for this account."
        case .unavailable(let message):
            message
        case .unknown, .playable:
            nil
        }
    }
}

private extension Error {
    var playbackAvailability: PlaybackAvailability {
        guard let playbackError = self as? MusicPlaybackError else {
            return .unavailable("Playback is unavailable right now.")
        }

        switch playbackError {
        case .authorizationDenied:
            return .unavailable("Apple Music access was denied.")
        case .authorizationRestricted:
            return .unavailable("Apple Music access is restricted on this device.")
        case .subscriptionRequired:
            return .subscriptionRequired
        case .playbackUnavailable(let message):
            return .unavailable(message)
        case .songUnavailable:
            return .unavailable("This song is unavailable for full playback.")
        }
    }

    var playbackMessage: String {
        playbackAvailability.displayMessage ?? "Playback is unavailable right now."
    }
}
