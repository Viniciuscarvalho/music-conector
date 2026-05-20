//
//  HomeDependencies.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import SwiftData
import SwiftUI

@MainActor
struct HomeDependencies {
    let makeRepository: (ModelContext) -> any HomeSongRepository

    static let live = HomeDependencies { modelContext in
        DefaultHomeSongRepository(
            catalogService: MusicKitCatalogService(),
            recentSongsStore: SwiftDataRecentSongsStore(modelContext: modelContext)
        )
    }
}

private struct HomeDependenciesKey: EnvironmentKey {
    @MainActor static let defaultValue = HomeDependencies.live
}

extension EnvironmentValues {
    var homeDependencies: HomeDependencies {
        get { self[HomeDependenciesKey.self] }
        set { self[HomeDependenciesKey.self] = newValue }
    }
}
