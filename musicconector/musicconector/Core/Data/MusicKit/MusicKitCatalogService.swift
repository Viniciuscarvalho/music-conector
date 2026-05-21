//
//  MusicKitCatalogService.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation
import MusicKit

struct MusicKitCatalogService: MusicCatalogServicing {
    private let authorizationProvider: MusicAuthorizationProviding

    init(authorizationProvider: MusicAuthorizationProviding = MusicKitAuthorizationProvider()) {
        self.authorizationProvider = authorizationProvider
    }

    func searchSongs(term: String, page: PageRequest) async throws -> PagedResult<Song> {
        let trimmedTerm = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTerm.isEmpty else {
            throw MusicCatalogError.emptySearchTerm
        }

        await requestAuthorizationIfNeeded()

        var request = MusicCatalogSearchRequest(term: trimmedTerm, types: [MusicKit.Song.self])
        request.limit = page.limit
        request.offset = page.offset

        let response = try await request.response()
        var songs: [Song] = []
        songs.reserveCapacity(response.songs.count)

        for song in response.songs {
            let detailedSong = try await song.with(.albums)
            songs.append(try Song(validatingMusicKitSong: detailedSong))
        }

        let nextPage = songs.count == page.limit ? page.next : nil

        return PagedResult(items: songs, page: page, nextPage: nextPage)
    }

    func song(id: Song.ID) async throws -> Song {
        await requestAuthorizationIfNeeded()

        var request = MusicCatalogResourceRequest<MusicKit.Song>(
            matching: \.id,
            equalTo: MusicItemID(id)
        )
        request.limit = 1
        request.properties = [.albums]

        let response = try await request.response()
        guard let song = response.items.first else {
            throw MusicCatalogError.songNotFound(id)
        }

        return try Song(validatingMusicKitSong: song)
    }

    func album(id: Album.ID) async throws -> Album {
        await requestAuthorizationIfNeeded()

        var request = MusicCatalogResourceRequest<MusicKit.Album>(
            matching: \.id,
            equalTo: MusicItemID(id)
        )
        request.limit = 1
        request.properties = [.tracks]

        let response = try await request.response()
        guard let album = response.items.first else {
            throw MusicCatalogError.albumNotFound(id)
        }

        return try Album(validatingMusicKitAlbum: album)
    }

    private func requestAuthorizationIfNeeded() async {
        guard await authorizationProvider.currentStatus() == .notDetermined else { return }
        _ = await authorizationProvider.requestAuthorization()
    }
}
