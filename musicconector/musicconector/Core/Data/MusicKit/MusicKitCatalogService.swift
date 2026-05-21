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

        try await requestAuthorizationIfNeeded()

        var request = MusicCatalogSearchRequest(term: trimmedTerm, types: [MusicKit.Song.self])
        request.limit = page.limit
        request.offset = page.offset

        let response: MusicCatalogSearchResponse
        do {
            response = try await request.response()
        } catch {
            throw Self.catalogError(from: error)
        }

        var songs: [Song] = []
        songs.reserveCapacity(response.songs.count)

        for song in response.songs {
            do {
                let detailedSong = try await song.with(.albums)
                songs.append(try Song(validatingMusicKitSong: detailedSong))
            } catch {
                throw Self.catalogError(from: error)
            }
        }

        let nextPage = songs.count == page.limit ? page.next : nil

        return PagedResult(items: songs, page: page, nextPage: nextPage)
    }

    func song(id: Song.ID) async throws -> Song {
        try await requestAuthorizationIfNeeded()

        var request = MusicCatalogResourceRequest<MusicKit.Song>(
            matching: \.id,
            equalTo: MusicItemID(id)
        )
        request.limit = 1
        request.properties = [.albums]

        let response: MusicCatalogResourceResponse<MusicKit.Song>
        do {
            response = try await request.response()
        } catch {
            throw Self.catalogError(from: error)
        }

        guard let song = response.items.first else {
            throw MusicCatalogError.songNotFound(id)
        }

        return try Song(validatingMusicKitSong: song)
    }

    func albumID(for song: Song) async throws -> Album.ID {
        if let albumID = song.resolvedAlbumID {
            return albumID
        }

        let albumTitle = song.albumTitle?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        guard let albumTitle else {
            throw MusicCatalogError.invalidCatalogData(song.id)
        }

        try await requestAuthorizationIfNeeded()

        var request = MusicCatalogSearchRequest(term: "\(albumTitle) \(song.artist.name)", types: [MusicKit.Album.self])
        request.limit = 10
        request.offset = 0

        let response: MusicCatalogSearchResponse
        do {
            response = try await request.response()
        } catch {
            throw Self.catalogError(from: error)
        }

        let matchedAlbum = response.albums.first { album in
            album.title.normalizedForCatalogMatch == albumTitle.normalizedForCatalogMatch
                && album.artistName.normalizedForCatalogMatch.contains(song.artist.name.normalizedForCatalogMatch)
        } ?? response.albums.first { album in
            album.title.normalizedForCatalogMatch == albumTitle.normalizedForCatalogMatch
        } ?? response.albums.first

        guard let albumID = matchedAlbum?.id.rawValue.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty else {
            throw MusicCatalogError.albumNotFound(albumTitle)
        }

        return albumID
    }

    func album(id: Album.ID) async throws -> Album {
        guard !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw MusicCatalogError.albumNotFound(id)
        }

        try await requestAuthorizationIfNeeded()

        var request = MusicCatalogResourceRequest<MusicKit.Album>(
            matching: \.id,
            equalTo: MusicItemID(id)
        )
        request.limit = 1
        request.properties = [.tracks]

        let response: MusicCatalogResourceResponse<MusicKit.Album>
        do {
            response = try await request.response()
        } catch {
            throw Self.catalogError(from: error)
        }

        guard let album = response.items.first else {
            throw MusicCatalogError.albumNotFound(id)
        }

        return try Album(validatingMusicKitAlbum: album)
    }

    private func requestAuthorizationIfNeeded() async throws {
        let status = await authorizationProvider.currentStatus()
        switch status {
        case .authorized:
            return
        case .notDetermined, .unknown:
            let requestedStatus = await authorizationProvider.requestAuthorization()
            switch requestedStatus {
            case .authorized:
                return
            case .restricted:
                throw MusicCatalogError.authorizationRestricted
            case .denied, .notDetermined, .unknown:
                throw MusicCatalogError.authorizationDenied
            }
        case .restricted:
            throw MusicCatalogError.authorizationRestricted
        case .denied:
            throw MusicCatalogError.authorizationDenied
        }
    }

    private static func catalogError(from error: Error) -> Error {
        error.isAuthorizationUnavailable ? MusicCatalogError.unauthorized : error
    }
}

private extension String {
    var normalizedForCatalogMatch: String {
        folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
