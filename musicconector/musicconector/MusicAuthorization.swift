//
//  MusicAuthorization.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation
import MusicKit

enum MusicAuthorizationState: Equatable {
    case notDetermined
    case authorized
    case denied
    case restricted
    case unknown
}

protocol MusicAuthorizationProviding {
    func currentStatus() async -> MusicAuthorizationState
}

struct MusicKitAuthorizationProvider: MusicAuthorizationProviding {
    func currentStatus() async -> MusicAuthorizationState {
        switch MusicAuthorization.currentStatus {
        case .notDetermined:
            return .notDetermined
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        @unknown default:
            return .unknown
        }
    }
}
