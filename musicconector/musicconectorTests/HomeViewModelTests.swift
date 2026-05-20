//
//  HomeViewModelTests.swift
//  musicconectorTests
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation
import Testing
@testable import musicconector

@MainActor
struct HomeViewModelTests {

    @Test func loadRecentSongsShowsCachedSongsWithoutCatalogSearch() async {
        let repository = HomeRepositoryFake(recentSongs: [
            sampleHomeSong(id: "recent-1", title: "Purple Rain"),
            sampleHomeSong(id: "recent-2", title: "Get Lucky")
        ])
        let viewModel = HomeViewModel(repository: repository)

        await viewModel.loadRecentSongs()

        #expect(viewModel.state == .recents)
        #expect(viewModel.songs.map(\.id) == ["recent-1", "recent-2"])
        #expect(repository.searchRequests.isEmpty)
    }

    @Test func searchReturnsMatchingSongsFromCatalog() async {
        let repository = HomeRepositoryFake()
        repository.pages[0] = PagedResult(
            items: [
                sampleHomeSong(id: "song-1", title: "Get Lucky"),
                sampleHomeSong(id: "song-2", title: "Around the World")
            ],
            page: PageRequest(limit: 25, offset: 0),
            nextPage: nil
        )
        let viewModel = HomeViewModel(repository: repository)

        await viewModel.search(term: " daft punk ")

        #expect(viewModel.state == .results)
        #expect(viewModel.searchResults.map(\.id) == ["song-1", "song-2"])
        #expect(repository.searchRequests.map(\.term) == ["daft punk"])
    }

    @Test func searchEmptyResultShowsEmptyState() async {
        let repository = HomeRepositoryFake()
        repository.pages[0] = PagedResult(
            items: [],
            page: PageRequest(limit: 25, offset: 0),
            nextPage: nil
        )
        let viewModel = HomeViewModel(repository: repository)

        await viewModel.search(term: "unknown song")

        #expect(viewModel.state == .empty)
        #expect(viewModel.searchResults.isEmpty)
    }

    @Test func scrollingNearBottomRequestsNextPageOnce() async {
        let repository = HomeRepositoryFake()
        let firstPage = PageRequest(limit: 25, offset: 0)
        let secondPage = firstPage.next
        repository.pages[0] = PagedResult(
            items: [
                sampleHomeSong(id: "song-1"),
                sampleHomeSong(id: "song-2"),
                sampleHomeSong(id: "song-3")
            ],
            page: firstPage,
            nextPage: secondPage
        )
        repository.pages[25] = PagedResult(
            items: [
                sampleHomeSong(id: "song-4"),
                sampleHomeSong(id: "song-5")
            ],
            page: secondPage,
            nextPage: nil
        )
        let viewModel = HomeViewModel(repository: repository)

        await viewModel.search(term: "prince")
        await viewModel.loadNextPageIfNeeded(currentSongID: "song-3")
        await viewModel.loadNextPageIfNeeded(currentSongID: "song-5")

        #expect(viewModel.searchResults.map(\.id) == ["song-1", "song-2", "song-3", "song-4", "song-5"])
        #expect(repository.searchRequests.map(\.page.offset) == [0, 25])
    }

    @Test func scrollingAwayFromBottomDoesNotRequestNextPage() async {
        let repository = HomeRepositoryFake()
        let firstPage = PageRequest(limit: 25, offset: 0)
        repository.pages[0] = PagedResult(
            items: [
                sampleHomeSong(id: "song-1"),
                sampleHomeSong(id: "song-2"),
                sampleHomeSong(id: "song-3"),
                sampleHomeSong(id: "song-4"),
                sampleHomeSong(id: "song-5")
            ],
            page: firstPage,
            nextPage: firstPage.next
        )
        let viewModel = HomeViewModel(repository: repository)

        await viewModel.search(term: "madonna")
        await viewModel.loadNextPageIfNeeded(currentSongID: "song-1")

        #expect(repository.searchRequests.map(\.page.offset) == [0])
    }

    @Test func failedSearchShowsErrorState() async {
        let repository = HomeRepositoryFake()
        repository.searchError = MusicCatalogError.songNotFound("missing")
        let viewModel = HomeViewModel(repository: repository)

        await viewModel.search(term: "missing")

        #expect(viewModel.state == .error("We could not load songs for this search."))
        #expect(viewModel.searchResults.isEmpty)
    }

    @Test func recentStoreFailureShowsOfflineState() async {
        let viewModel = HomeViewModel(repository: HomeRepositoryFake(recentSongsError: MusicCatalogError.emptySearchTerm))

        await viewModel.loadRecentSongs()

        #expect(viewModel.state == .offline("Recent songs are unavailable offline on this device."))
        #expect(viewModel.recentSongs.isEmpty)
    }
}

@MainActor
private final class HomeRepositoryFake: HomeSongRepository {
    struct SearchRequest {
        let term: String
        let page: PageRequest
    }

    var recentSongs: [Song]
    var recentSongsError: Error?
    var pages: [Int: PagedResult<Song>] = [:]
    var searchError: Error?
    private(set) var searchRequests: [SearchRequest] = []

    init(recentSongs: [Song] = [], recentSongsError: Error? = nil) {
        self.recentSongs = recentSongs
        self.recentSongsError = recentSongsError
    }

    func recentSongs(limit: Int) async throws -> [Song] {
        if let error = recentSongsError {
            throw error
        }

        return Array(recentSongs.prefix(limit))
    }

    func searchSongs(term: String, page: PageRequest) async throws -> PagedResult<Song> {
        searchRequests.append(SearchRequest(term: term, page: page))

        if let searchError {
            throw searchError
        }

        return pages[page.offset] ?? PagedResult(items: [], page: page, nextPage: nil)
    }
}

@MainActor
private func sampleHomeSong(id: String, title: String = "Get Lucky") -> Song {
    Song(
        id: id,
        title: title,
        artist: Artist(id: "artist-\(id)", name: "Artist \(id)"),
        albumTitle: "Album \(id)",
        artworkURL: URL(string: "https://example.com/\(id).jpg"),
        duration: 240
    )
}
