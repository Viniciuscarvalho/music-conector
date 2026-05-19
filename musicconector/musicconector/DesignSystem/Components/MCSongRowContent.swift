//
//  MCSongRowContent.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation

struct MCSongRowContent: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let artworkURL: URL?

    init(id: String, title: String, subtitle: String, artworkURL: URL? = nil) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.artworkURL = artworkURL
    }
}
