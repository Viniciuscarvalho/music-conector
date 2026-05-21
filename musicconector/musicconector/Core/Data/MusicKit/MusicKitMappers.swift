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
        let album = musicKitSong.albums?.first

        self.init(
            id: musicKitSong.id.rawValue,
            title: musicKitSong.title,
            artist: Artist(
                id: musicKitSong.artistName,
                name: musicKitSong.artistName,
                artworkURL: nil
            ),
            albumTitle: musicKitSong.albumTitle,
            albumID: album?.id.rawValue.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            artworkURL: musicKitSong.artwork?.url(width: 512, height: 512),
            duration: musicKitSong.duration,
            releaseDate: musicKitSong.releaseDate
        )
    }

    init(validatingMusicKitSong musicKitSong: MusicKit.Song) throws {
        let songID = musicKitSong.id.rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let title = musicKitSong.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let artistName = musicKitSong.artistName.trimmingCharacters(in: .whitespacesAndNewlines)
        let album = musicKitSong.albums?.first

        guard !songID.isEmpty, !title.isEmpty, !artistName.isEmpty else {
            throw MusicCatalogError.invalidCatalogData(musicKitSong.id.rawValue)
        }

        let artist = Artist(
            id: artistName,
            name: artistName,
            artworkURL: nil
        )

        self.init(
            id: songID,
            title: title,
            artist: artist,
            albumTitle: musicKitSong.albumTitle?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            albumID: album?.id.rawValue.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            artworkURL: musicKitSong.artwork?.url(width: 512, height: 512),
            duration: musicKitSong.duration,
            releaseDate: musicKitSong.releaseDate
        )
    }
}

extension Song {
    init?(validatingMusicKitTrack musicKitTrack: MusicKit.Track, fallbackAlbum: MusicKit.Album) {
        guard case .song(let song) = musicKitTrack else { return nil }
        let songID = song.id.rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let title = song.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let artistName = song.artistName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !songID.isEmpty, !title.isEmpty, !artistName.isEmpty else {
            return nil
        }

        self.init(
            id: songID,
            title: title,
            artist: Artist(id: artistName, name: artistName),
            albumTitle: song.albumTitle ?? fallbackAlbum.title,
            albumID: fallbackAlbum.id.rawValue.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            artworkURL: song.artwork?.url(width: 512, height: 512) ?? fallbackAlbum.artwork?.url(width: 512, height: 512),
            duration: song.duration,
            releaseDate: song.releaseDate
        )
    }
}

extension Album {
    init(validatingMusicKitAlbum musicKitAlbum: MusicKit.Album) throws {
        let albumID = musicKitAlbum.id.rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let title = musicKitAlbum.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let artistName = musicKitAlbum.artistName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !albumID.isEmpty, !title.isEmpty, !artistName.isEmpty else {
            throw MusicCatalogError.invalidCatalogData(musicKitAlbum.id.rawValue)
        }

        let tracks = musicKitAlbum.tracks?.compactMap { track in
            Song(validatingMusicKitTrack: track, fallbackAlbum: musicKitAlbum)
        } ?? []

        self.init(
            id: albumID,
            title: title,
            artist: Artist(id: artistName, name: artistName),
            artworkURL: musicKitAlbum.artwork?.url(width: 512, height: 512),
            tracks: tracks
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
