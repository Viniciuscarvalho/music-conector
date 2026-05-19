//
//  MusicKitMappers.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation
import MusicKit

extension Song {
    init(musicKitSong: MusicKit.Song) {
        let artist = Artist(
            id: musicKitSong.artistName,
            name: musicKitSong.artistName,
            artworkURL: nil
        )

        self.init(
            id: musicKitSong.id.rawValue,
            title: musicKitSong.title,
            artist: artist,
            albumTitle: musicKitSong.albumTitle,
            albumID: nil,
            artworkURL: musicKitSong.artwork?.url(width: 512, height: 512),
            duration: musicKitSong.duration,
            releaseDate: musicKitSong.releaseDate
        )
    }
}

extension PlaybackStatus {
    init(musicKitStatus: MusicPlayer.PlaybackStatus) {
        switch musicKitStatus {
        case .stopped:
            self = .stopped
        case .playing:
            self = .playing
        case .paused:
            self = .paused
        case .interrupted:
            self = .interrupted
        case .seekingForward:
            self = .seekingForward
        case .seekingBackward:
            self = .seekingBackward
        @unknown default:
            self = .unknown
        }
    }
}
