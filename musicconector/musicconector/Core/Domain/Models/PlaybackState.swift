//
//  PlaybackState.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation

enum PlaybackAvailability: Equatable, Sendable {
    case unknown
    case playable
    case authorizationRequired
    case subscriptionRequired
    case unavailable(String)
}

enum PlaybackStatus: Equatable, Sendable {
    case stopped
    case playing
    case paused
    case interrupted
    case seekingForward
    case seekingBackward
    case unknown
}

struct PlaybackState: Equatable, Sendable {
    let authorization: MusicAuthorizationState
    let availability: PlaybackAvailability
    let status: PlaybackStatus
    let currentSong: Song?
    let elapsedTime: TimeInterval
    let duration: TimeInterval?

    init(
        authorization: MusicAuthorizationState,
        availability: PlaybackAvailability = .unknown,
        status: PlaybackStatus = .stopped,
        currentSong: Song? = nil,
        elapsedTime: TimeInterval = 0,
        duration: TimeInterval? = nil
    ) {
        self.authorization = authorization
        self.availability = availability
        self.status = status
        self.currentSong = currentSong
        self.elapsedTime = elapsedTime
        self.duration = duration
    }
}
