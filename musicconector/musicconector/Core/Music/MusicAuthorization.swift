//
//  MusicAuthorization.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation
import MusicKit

enum MusicAuthorizationState: Equatable, Sendable {
    case notDetermined
    case authorized
    case denied
    case restricted
    case unknown
}

protocol MusicAuthorizationProviding {
    func currentStatus() async -> MusicAuthorizationState
    func requestAuthorization() async -> MusicAuthorizationState
}

struct MusicKitAuthorizationProvider: MusicAuthorizationProviding {
    func currentStatus() async -> MusicAuthorizationState {
        MusicAuthorizationState(status: MusicAuthorization.currentStatus)
    }

    func requestAuthorization() async -> MusicAuthorizationState {
        MusicAuthorizationState(status: await MusicAuthorization.request())
    }
}

private extension MusicAuthorizationState {
    init(status: MusicAuthorization.Status) {
        switch status {
        case .notDetermined:
            self = .notDetermined
        case .authorized:
            self = .authorized
        case .denied:
            self = .denied
        case .restricted:
            self = .restricted
        @unknown default:
            self = .unknown
        }
    }
}
