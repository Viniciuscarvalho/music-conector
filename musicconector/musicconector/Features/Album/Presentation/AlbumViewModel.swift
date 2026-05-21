//
//  AlbumViewModel.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 21/05/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class AlbumViewModel {
    enum State: Equatable {
        case loading
        case loaded
        case empty
        case error(String)
    }

    let albumID: Album.ID
    private(set) var state: State = .loading
    private(set) var album: Album?
    private(set) var message: String?

    private let repository: any AlbumRepository

    init(albumID: Album.ID, repository: any AlbumRepository) {
        self.albumID = albumID
        self.repository = repository
    }

    var tracks: [Song] {
        album?.tracks ?? []
    }

    func load() async {
        if album == nil {
            state = .loading
        }
        message = nil

        let cachedAlbum = try? await repository.cachedAlbum(id: albumID)
        if let cachedAlbum {
            apply(cachedAlbum)
        }

        do {
            let fetchedAlbum = try await repository.fetchAlbum(id: albumID)
            apply(fetchedAlbum)
            try? await repository.saveViewedAlbum(fetchedAlbum)
        } catch {
            if cachedAlbum != nil {
                message = Self.message(forCachedFallbackError: error)
            } else {
                state = .error(Self.message(forLoadError: error))
            }
        }
    }

    private func apply(_ album: Album) {
        self.album = album
        state = album.tracks.isEmpty ? .empty : .loaded
    }

    private static func message(forCachedFallbackError error: Error) -> String {
        if error.isConnectionUnavailable {
            return "Showing the cached album because there is no internet connection."
        }

        return "Showing the cached album because the latest version could not be loaded."
    }

    private static func message(forLoadError error: Error) -> String {
        if error.isConnectionUnavailable {
            return "Check your internet connection and try again."
        }

        if case MusicCatalogError.invalidCatalogData = error {
            return "This album has incomplete metadata and cannot be displayed."
        }

        if case MusicCatalogError.albumNotFound = error {
            return "Album could not be found."
        }

        return "Album could not be loaded. Try again."
    }
}
