//
//  PlayerDependencies.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import SwiftData
import SwiftUI

@MainActor
struct PlayerDependencies {
    let makeRepository: (ModelContext) -> any PlayerRepository

    static let live = PlayerDependencies { modelContext in
        DefaultPlayerRepository(
            playbackManager: MusicKitPlaybackManager(),
            recentSongsStore: SwiftDataRecentSongsStore(modelContext: modelContext)
        )
    }
}

private struct PlayerDependenciesKey: EnvironmentKey {
    @MainActor static let defaultValue = PlayerDependencies.live
}

extension EnvironmentValues {
    var playerDependencies: PlayerDependencies {
        get { self[PlayerDependenciesKey.self] }
        set { self[PlayerDependenciesKey.self] = newValue }
    }
}
