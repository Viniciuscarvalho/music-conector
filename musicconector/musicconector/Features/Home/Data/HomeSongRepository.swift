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
    func albumID(for song: Song) async throws -> Album.ID
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
        let playedSongs = try await recentSongsStore.recentlyPlayed(limit: limit)
        let viewedSongs = try await recentSongsStore.recentlyViewed(limit: limit)
        return Self.mergedUniqueSongs(playedSongs + viewedSongs, limit: limit)
    }

    func searchSongs(term: String, page: PageRequest) async throws -> PagedResult<Song> {
        if page.offset == 0 {
            let cachedSongs = try await recentSongsStore.cachedSongs(matching: term, limit: page.limit)
            if !cachedSongs.isEmpty {
                return PagedResult(items: cachedSongs, page: page, nextPage: nil)
            }
        }

        do {
            let result = try await catalogService.searchSongs(term: term, page: page)
            for song in result.items {
                try? await recentSongsStore.saveViewedSong(song, viewedAt: .now)
            }
            return result
        } catch {
            guard page.offset == 0, error.isConnectionUnavailable || error.isAuthorizationUnavailable else {
                throw error
            }

            let cachedSongs = try await recentSongsStore.cachedSongs(matching: term, limit: page.limit)
            guard !cachedSongs.isEmpty else {
                throw error
            }

            return PagedResult(items: cachedSongs, page: page, nextPage: nil)
        }
    }

    func albumID(for song: Song) async throws -> Album.ID {
        try await catalogService.albumID(for: song)
    }

    private static func mergedUniqueSongs(_ songs: [Song], limit: Int) -> [Song] {
        var seenIDs = Set<Song.ID>()
        var uniqueSongs: [Song] = []

        for song in songs where seenIDs.insert(song.id).inserted {
            uniqueSongs.append(song)
            if uniqueSongs.count == limit {
                break
            }
        }

        return uniqueSongs
    }
}
