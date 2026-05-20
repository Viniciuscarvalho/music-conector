//
//  HomeSongRepository.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation

@MainActor
protocol HomeSongRepository {
    func recentSongs(limit: Int) async throws -> [Song]
    func searchSongs(term: String, page: PageRequest) async throws -> PagedResult<Song>
}

@MainActor
final class DefaultHomeSongRepository: HomeSongRepository {
    private let catalogService: MusicCatalogServicing
    private let recentSongsStore: RecentSongsStoring

    init(catalogService: MusicCatalogServicing, recentSongsStore: RecentSongsStoring) {
        self.catalogService = catalogService
        self.recentSongsStore = recentSongsStore
    }

    func recentSongs(limit: Int) async throws -> [Song] {
        try await recentSongsStore.recentlyPlayed(limit: limit)
    }

    func searchSongs(term: String, page: PageRequest) async throws -> PagedResult<Song> {
        try await catalogService.searchSongs(term: term, page: page)
    }
}
