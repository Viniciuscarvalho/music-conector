//
//  AlbumDependencies.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 21/05/26.
//

import SwiftData
import SwiftUI

@MainActor
struct AlbumDependencies {
    let makeRepository: (ModelContext) -> any AlbumRepository

    static let live = AlbumDependencies { modelContext in
        DefaultAlbumRepository(
            catalogService: MusicKitCatalogService(),
            recentSongsStore: SwiftDataRecentSongsStore(modelContext: modelContext)
        )
    }
}

private struct AlbumDependenciesKey: EnvironmentKey {
    @MainActor static let defaultValue = AlbumDependencies.live
}

extension EnvironmentValues {
    var albumDependencies: AlbumDependencies {
        get { self[AlbumDependenciesKey.self] }
        set { self[AlbumDependenciesKey.self] = newValue }
    }
}
