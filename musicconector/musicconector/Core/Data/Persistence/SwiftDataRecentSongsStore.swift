//
//  SwiftDataRecentSongsStore.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataRecentSongsStore: RecentSongsStoring {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func saveRecentlyPlayed(_ song: Song, playedAt: Date = .now) async throws {
        let songID = song.id
        let descriptor = FetchDescriptor<CachedSong>(
            predicate: #Predicate { cachedSong in
                cachedSong.id == songID
            }
        )

        let existingSong = try modelContext.fetch(descriptor).first
        let cachedSong = existingSong ?? CachedSong(
            id: song.id,
            title: song.title,
            artistName: song.artist.name
        )
        cachedSong.title = song.title
        cachedSong.artistName = song.artist.name
        cachedSong.albumTitle = song.albumTitle
        cachedSong.artworkURL = song.artworkURL
        cachedSong.lastPlayedAt = playedAt

        if existingSong == nil {
            modelContext.insert(cachedSong)
        }
        try modelContext.save()
    }

    func recentlyPlayed(limit: Int = 10) async throws -> [Song] {
        var descriptor = FetchDescriptor<CachedSong>(
            sortBy: [SortDescriptor(\.lastPlayedAt, order: .reverse)]
        )
        descriptor.fetchLimit = max(1, limit)

        return try modelContext.fetch(descriptor).map(Song.init(cachedSong:))
    }
}

private extension Song {
    init(cachedSong: CachedSong) {
        self.init(
            id: cachedSong.id,
            title: cachedSong.title,
            artist: Artist(id: cachedSong.artistName, name: cachedSong.artistName),
            albumTitle: cachedSong.albumTitle,
            artworkURL: cachedSong.artworkURL
        )
    }
}
