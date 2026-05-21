//
//  AlbumRepository.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 21/05/26.
//

import Foundation

@MainActor
protocol AlbumRepository {
    func cachedAlbum(id: Album.ID) async throws -> Album?
    func fetchAlbum(id: Album.ID) async throws -> Album
    func saveViewedAlbum(_ album: Album) async throws
}

@MainActor
final class DefaultAlbumRepository: AlbumRepository {
    private let catalogService: MusicCatalogServicing
    private let recentSongsStore: RecentSongsStoring

    init(catalogService: MusicCatalogServicing, recentSongsStore: RecentSongsStoring) {
        self.catalogService = catalogService
        self.recentSongsStore = recentSongsStore
    }

    func cachedAlbum(id: Album.ID) async throws -> Album? {
        try await recentSongsStore.cachedAlbum(id: id)
    }

    func fetchAlbum(id: Album.ID) async throws -> Album {
        try await catalogService.album(id: id)
    }

    func saveViewedAlbum(_ album: Album) async throws {
        try await recentSongsStore.saveViewedAlbum(album, viewedAt: .now)
    }
}
