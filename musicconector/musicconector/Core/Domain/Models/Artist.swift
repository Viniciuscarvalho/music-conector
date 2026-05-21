//
//  Artist.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation

struct Artist: Identifiable, Equatable, Hashable, Sendable {
    let id: String
    let name: String
    let artworkURL: URL?

    init(id: String, name: String, artworkURL: URL? = nil) {
        self.id = id
        self.name = name
        self.artworkURL = artworkURL
    }
}
