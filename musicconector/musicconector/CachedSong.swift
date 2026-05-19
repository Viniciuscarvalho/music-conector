//
//  CachedSong.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation
import SwiftData

@Model
final class CachedSong {
    @Attribute(.unique) var id: String
    var title: String
    var artistName: String
    var albumTitle: String?
    var artworkURL: URL?
    var lastPlayedAt: Date

    init(
        id: String,
        title: String,
        artistName: String,
        albumTitle: String? = nil,
        artworkURL: URL? = nil,
        lastPlayedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.artistName = artistName
        self.albumTitle = albumTitle
        self.artworkURL = artworkURL
        self.lastPlayedAt = lastPlayedAt
    }
}
