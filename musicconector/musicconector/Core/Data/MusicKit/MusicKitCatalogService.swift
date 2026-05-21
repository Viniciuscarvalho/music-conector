//
//  MusicKitCatalogService.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation
import MusicKit

struct MusicKitCatalogService: MusicCatalogServicing {

    func searchSongs(term: String, page: PageRequest) async throws -> PagedResult<Song> {
        let trimmedTerm = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTerm.isEmpty else {
            throw MusicCatalogError.emptySearchTerm
        }

        var request = MusicCatalogSearchRequest(term: trimmedTerm, types: [MusicKit.Song.self])
        request.limit = page.limit
        request.offset = page.offset

        let response = try await request.response()
        let songs = try response.songs.map(Song.init(validatingMusicKitSong:))
        let nextPage = songs.count == page.limit ? page.next : nil

        return PagedResult(items: songs, page: page, nextPage: nextPage)
    }

    func song(id: Song.ID) async throws -> Song {
        var request = MusicCatalogResourceRequest<MusicKit.Song>(
            matching: \.id,
            equalTo: MusicItemID(id)
        )
        request.limit = 1

        let response = try await request.response()
        guard let song = response.items.first else {
            throw MusicCatalogError.songNotFound(id)
        }

        return try Song(validatingMusicKitSong: song)
    }
}
