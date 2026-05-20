//
//  CachedAlbum.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation
import SwiftData

@Model
final class CachedAlbum {
    @Attribute(.unique) var id: String
    var title: String
    var artistName: String
    var artistID: String
    var artworkURL: URL?
    var trackIDs: [String]
    var updatedAt: Date

    init(
        id: String,
        title: String,
        artistName: String,
        artistID: String? = nil,
        artworkURL: URL? = nil,
        trackIDs: [String] = [],
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.artistName = artistName
        self.artistID = artistID ?? artistName
        self.artworkURL = artworkURL
        self.trackIDs = trackIDs
        self.updatedAt = updatedAt
    }
}
