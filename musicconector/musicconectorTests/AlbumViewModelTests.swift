//
//  AlbumViewModelTests.swift
//  musicconectorTests
//
//  Created by Vinicius Carvalho on 21/05/26.
//

import Foundation
import Testing
@testable import musicconector

@MainActor
struct AlbumViewModelTests {

    @Test func loadFetchesAlbumCachesItAndShowsTracks() async {
        let album = sampleAlbum(id: "album", tracks: [sampleAlbumTrack(id: "track-1")])
        let repository = AlbumRepositoryFake(remoteAlbum: album)
        let viewModel = AlbumViewModel(albumID: album.id, repository: repository)

        await viewModel.load()

        #expect(viewModel.state == .loaded)
        #expect(viewModel.album?.id == album.id)
        #expect(viewModel.tracks.map(\.id) == ["track-1"])
        #expect(repository.savedAlbumIDs == [album.id])
    }

    @Test func loadShowsEmptyStateWhenAlbumHasNoTracks() async {
        let album = sampleAlbum(id: "empty", tracks: [])
        let repository = AlbumRepositoryFake(remoteAlbum: album)
        let viewModel = AlbumViewModel(albumID: album.id, repository: repository)

        await viewModel.load()

        #expect(viewModel.state == .empty)
        #expect(viewModel.album?.id == album.id)
        #expect(viewModel.tracks.isEmpty)
    }

    @Test func loadShowsErrorWhenRemoteFailsWithoutCache() async {
        let repository = AlbumRepositoryFake(remoteError: URLError(.notConnectedToInternet))
        let viewModel = AlbumViewModel(albumID: "album", repository: repository)

        await viewModel.load()

        #expect(viewModel.state == .error("Check your internet connection and try again."))
        #expect(viewModel.album == nil)
    }

    @Test func loadRendersCachedAlbumWhenRemoteFails() async {
        let cachedAlbum = sampleAlbum(id: "cached", tracks: [sampleAlbumTrack(id: "cached-track")])
        let repository = AlbumRepositoryFake(
            cachedAlbum: cachedAlbum,
            remoteError: URLError(.timedOut)
        )
        let viewModel = AlbumViewModel(albumID: cachedAlbum.id, repository: repository)

        await viewModel.load()

        #expect(viewModel.state == .loaded)
        #expect(viewModel.album?.id == cachedAlbum.id)
        #expect(viewModel.tracks.map(\.id) == ["cached-track"])
        #expect(viewModel.message == "Showing the cached album because there is no internet connection.")
        #expect(repository.savedAlbumIDs.isEmpty)
    }
}

@MainActor
private final class AlbumRepositoryFake: AlbumRepository {
    var cachedAlbum: Album?
    var remoteAlbum: Album?
    var remoteError: Error?
    private(set) var savedAlbumIDs: [Album.ID] = []

    init(cachedAlbum: Album? = nil, remoteAlbum: Album? = nil, remoteError: Error? = nil) {
        self.cachedAlbum = cachedAlbum
        self.remoteAlbum = remoteAlbum
        self.remoteError = remoteError
    }

    func cachedAlbum(id: Album.ID) async throws -> Album? {
        cachedAlbum
    }

    func fetchAlbum(id: Album.ID) async throws -> Album {
        if let remoteError {
            throw remoteError
        }

        return remoteAlbum ?? sampleAlbum(id: id, tracks: [])
    }

    func saveViewedAlbum(_ album: Album) async throws {
        savedAlbumIDs.append(album.id)
    }
}

@MainActor
private func sampleAlbum(id: Album.ID, tracks: [Song]) -> Album {
    Album(
        id: id,
        title: "Random Access Memories",
        artist: Artist(id: "daft-punk", name: "Daft Punk"),
        artworkURL: URL(string: "https://example.com/\(id).jpg"),
        tracks: tracks
    )
}

@MainActor
private func sampleAlbumTrack(id: Song.ID) -> Song {
    Song(
        id: id,
        title: "Get Lucky",
        artist: Artist(id: "daft-punk", name: "Daft Punk feat. Pharrell Williams"),
        albumTitle: "Random Access Memories",
        albumID: "album",
        artworkURL: URL(string: "https://example.com/\(id).jpg"),
        duration: 248
    )
}
