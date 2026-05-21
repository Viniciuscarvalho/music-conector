//
//  Song.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation

struct Song: Identifiable, Equatable, Hashable, Sendable {
    let id: String
    let title: String
    let artist: Artist
    let albumTitle: String?
    let albumID: String?
    let artworkURL: URL?
    let duration: TimeInterval?
    let releaseDate: Date?

    init(
        id: String,
        title: String,
        artist: Artist,
        albumTitle: String? = nil,
        albumID: String? = nil,
        artworkURL: URL? = nil,
        duration: TimeInterval? = nil,
        releaseDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.albumTitle = albumTitle
        self.albumID = albumID
        self.artworkURL = artworkURL
        self.duration = duration
        self.releaseDate = releaseDate
    }
}
