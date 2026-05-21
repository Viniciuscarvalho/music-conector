//
//  MusicCatalogServicing.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation

protocol MusicCatalogServicing {
    func searchSongs(term: String, page: PageRequest) async throws -> PagedResult<Song>
    func song(id: Song.ID) async throws -> Song
    func albumID(for song: Song) async throws -> Album.ID
    func album(id: Album.ID) async throws -> Album
}

enum MusicCatalogError: Error, Equatable {
    case emptySearchTerm
    case authorizationDenied
    case authorizationRestricted
    case unauthorized
    case albumNotFound(String)
    case invalidCatalogData(String)
    case songNotFound(String)
}
