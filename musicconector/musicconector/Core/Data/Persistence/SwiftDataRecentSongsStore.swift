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
        let cachedSong = try upsertCachedSong(song, updatedAt: playedAt)
        let existingRecentPlay = try fetchRecentPlay(songID: song.id)
        let recentPlay = existingRecentPlay ?? RecentPlay(songID: song.id)
        recentPlay.playedAt = playedAt
        recentPlay.song = cachedSong

        if existingRecentPlay == nil {
            modelContext.insert(recentPlay)
        }
        try modelContext.save()
    }

    func saveViewedSong(_ song: Song, viewedAt: Date = .now) async throws {
        _ = try upsertCachedSong(song, updatedAt: viewedAt)
        try modelContext.save()
    }

    func saveViewedAlbum(_ album: Album, viewedAt: Date = .now) async throws {
        let albumID = album.id
        let descriptor = FetchDescriptor<CachedAlbum>(
            predicate: #Predicate { cachedAlbum in
                cachedAlbum.id == albumID
            }
        )

        let existingAlbum = try modelContext.fetch(descriptor).first
        let cachedAlbum = existingAlbum ?? CachedAlbum(
            id: album.id,
            title: album.title,
            artistName: album.artist.name,
            artistID: album.artist.id
        )
        cachedAlbum.title = album.title
        cachedAlbum.artistName = album.artist.name
        cachedAlbum.artistID = album.artist.id
        cachedAlbum.artworkURL = album.artworkURL
        cachedAlbum.trackIDs = album.tracks.map(\.id)
        cachedAlbum.updatedAt = viewedAt

        if existingAlbum == nil {
            modelContext.insert(cachedAlbum)
        }

        for track in album.tracks {
            _ = try upsertCachedSong(track, updatedAt: viewedAt)
        }

        try modelContext.save()
    }

    func recentlyPlayed(limit: Int = 10) async throws -> [Song] {
        var descriptor = FetchDescriptor<RecentPlay>(
            sortBy: [SortDescriptor(\.playedAt, order: .reverse)]
        )
        descriptor.fetchLimit = max(1, limit)

        return try modelContext.fetch(descriptor).compactMap { recentPlay in
            guard let cachedSong = recentPlay.song else { return nil }
            return Song(cachedSong: cachedSong)
        }
    }

    func cachedSong(id: Song.ID) async throws -> Song? {
        try fetchCachedSong(id: id).map(Song.init(cachedSong:))
    }

    func cachedAlbum(id: Album.ID) async throws -> Album? {
        let albumID = id
        let descriptor = FetchDescriptor<CachedAlbum>(
            predicate: #Predicate { cachedAlbum in
                cachedAlbum.id == albumID
            }
        )

        guard let cachedAlbum = try modelContext.fetch(descriptor).first else {
            return nil
        }

        let tracks = try cachedAlbum.trackIDs.compactMap { trackID in
            try fetchCachedSong(id: trackID).map(Song.init(cachedSong:))
        }

        return Album(cachedAlbum: cachedAlbum, tracks: tracks)
    }

    private func upsertCachedSong(_ song: Song, updatedAt: Date) throws -> CachedSong {
        let songID = song.id
        let existingSong = try fetchCachedSong(id: songID)
        let cachedSong = existingSong ?? CachedSong(
            id: song.id,
            title: song.title,
            artistName: song.artist.name,
            artistID: song.artist.id
        )
        cachedSong.title = song.title
        cachedSong.artistName = song.artist.name
        cachedSong.artistID = song.artist.id
        cachedSong.albumTitle = song.albumTitle
        cachedSong.albumID = song.albumID
        cachedSong.artworkURL = song.artworkURL
        cachedSong.duration = song.duration
        cachedSong.releaseDate = song.releaseDate
        cachedSong.updatedAt = updatedAt

        if existingSong == nil {
            modelContext.insert(cachedSong)
        }
        return cachedSong
    }

    private func fetchCachedSong(id: Song.ID) throws -> CachedSong? {
        let songID = id
        let descriptor = FetchDescriptor<CachedSong>(
            predicate: #Predicate { cachedSong in
                cachedSong.id == songID
            }
        )

        return try modelContext.fetch(descriptor).first
    }

    private func fetchRecentPlay(songID: Song.ID) throws -> RecentPlay? {
        let id = songID
        let descriptor = FetchDescriptor<RecentPlay>(
            predicate: #Predicate { recentPlay in
                recentPlay.songID == id
            }
        )

        return try modelContext.fetch(descriptor).first
    }
}

private extension Song {
    init(cachedSong: CachedSong) {
        self.init(
            id: cachedSong.id,
            title: cachedSong.title,
            artist: Artist(id: cachedSong.artistID ?? cachedSong.artistName, name: cachedSong.artistName),
            albumTitle: cachedSong.albumTitle,
            albumID: cachedSong.albumID,
            artworkURL: cachedSong.artworkURL,
            duration: cachedSong.duration,
            releaseDate: cachedSong.releaseDate
        )
    }
}

private extension Album {
    init(cachedAlbum: CachedAlbum, tracks: [Song]) {
        self.init(
            id: cachedAlbum.id,
            title: cachedAlbum.title,
            artist: Artist(id: cachedAlbum.artistID, name: cachedAlbum.artistName),
            artworkURL: cachedAlbum.artworkURL,
            tracks: tracks
        )
    }
}
