//
//  MusicPlaybackManaging.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation

protocol MusicPlaybackManaging {
    func requestAuthorization() async -> MusicAuthorizationState
    func currentState() async -> PlaybackState
    func play(song: Song) async throws
    func pause() async
    func resume() async throws
    func progressUpdates(every interval: Duration) -> AsyncStream<PlaybackState>
}

enum MusicPlaybackError: Error, Equatable {
    case authorizationDenied
    case authorizationRestricted
    case subscriptionRequired
    case songUnavailable(String)
}
