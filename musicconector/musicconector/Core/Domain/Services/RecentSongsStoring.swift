//
//  RecentSongsStoring.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation

protocol RecentSongsStoring {
    func saveRecentlyPlayed(_ song: Song, playedAt: Date) async throws
    func saveViewedSong(_ song: Song, viewedAt: Date) async throws
    func saveViewedAlbum(_ album: Album, viewedAt: Date) async throws
    func recentlyPlayed(limit: Int) async throws -> [Song]
    func recentlyViewed(limit: Int) async throws -> [Song]
    func cachedSongs(matching term: String, limit: Int) async throws -> [Song]
    func cachedSong(id: Song.ID) async throws -> Song?
    func cachedAlbum(id: Album.ID) async throws -> Album?
}
