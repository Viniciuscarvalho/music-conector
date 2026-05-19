//
//  Album.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation

struct Album: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let artist: Artist
    let artworkURL: URL?
    let tracks: [Song]

    init(id: String, title: String, artist: Artist, artworkURL: URL? = nil, tracks: [Song] = []) {
        self.id = id
        self.title = title
        self.artist = artist
        self.artworkURL = artworkURL
        self.tracks = tracks
    }
}
