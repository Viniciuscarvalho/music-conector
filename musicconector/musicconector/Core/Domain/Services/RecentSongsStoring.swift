//
//  RecentSongsStoring.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation

protocol RecentSongsStoring {
    func saveRecentlyPlayed(_ song: Song, playedAt: Date) async throws
    func recentlyPlayed(limit: Int) async throws -> [Song]
}
