//
//  RecentPlay.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation
import SwiftData

@Model
final class RecentPlay {
    @Attribute(.unique) var songID: String
    var playedAt: Date
    var song: CachedSong?

    init(songID: String, playedAt: Date = .now, song: CachedSong? = nil) {
        self.songID = songID
        self.playedAt = playedAt
        self.song = song
    }
}
