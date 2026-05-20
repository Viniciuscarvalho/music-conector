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
        let catalogService = HomeCatalogServiceFake()
        let recentSongsStore = HomeRecentSongsStoreFake(recentSongs: [
            sampleHomeSong(id: "recent-1", title: "Purple Rain"),
            sampleHomeSong(id: "recent-2", title: "Get Lucky")
        ])
        let viewModel = HomeViewModel(catalogService: catalogService, recentSongsStore: recentSongsStore)

        await viewModel.loadRecentSongs()

        #expect(viewModel.state == .recents)
        #expect(viewModel.songs.map(\.id) == ["recent-1", "recent-2"])
        #expect(catalogService.searchRequests.isEmpty)
    }

    @Test func searchReturnsMatchingSongsFromCatalog() async {
        let catalogService = HomeCatalogServiceFake()
        catalogService.pages[0] = PagedResult(
            items: [
                sampleHomeSong(id: "song-1", title: "Get Lucky"),
                sampleHomeSong(id: "song-2", title: "Around the World")
            ],
            page: PageRequest(limit: 25, offset: 0),
            nextPage: nil
        )
        let viewModel = HomeViewModel(catalogService: catalogService)

        await viewModel.search(term: " daft punk ")

        #expect(viewModel.state == .results)
        #expect(viewModel.searchResults.map(\.id) == ["song-1", "song-2"])
        #expect(catalogService.searchRequests.map(\.term) == ["daft punk"])
    }

    @Test func searchEmptyResultShowsEmptyState() async {
        let catalogService = HomeCatalogServiceFake()
        catalogService.pages[0] = PagedResult(
            items: [],
            page: PageRequest(limit: 25, offset: 0),
            nextPage: nil
        )
        let viewModel = HomeViewModel(catalogService: catalogService)

        await viewModel.search(term: "unknown song")

        #expect(viewModel.state == .empty)
        #expect(viewModel.searchResults.isEmpty)
    }

    @Test func scrollingNearBottomRequestsNextPageOnce() async {
        let catalogService = HomeCatalogServiceFake()
        let firstPage = PageRequest(limit: 25, offset: 0)
        let secondPage = firstPage.next
        catalogService.pages[0] = PagedResult(
            items: [
                sampleHomeSong(id: "song-1"),
                sampleHomeSong(id: "song-2"),
                sampleHomeSong(id: "song-3")
            ],
            page: firstPage,
            nextPage: secondPage
        )
        catalogService.pages[25] = PagedResult(
            items: [
                sampleHomeSong(id: "song-4"),
                sampleHomeSong(id: "song-5")
            ],
            page: secondPage,
            nextPage: nil
        )
        let viewModel = HomeViewModel(catalogService: catalogService)

        await viewModel.search(term: "prince")
        await viewModel.loadNextPageIfNeeded(currentSongID: "song-3")
        await viewModel.loadNextPageIfNeeded(currentSongID: "song-5")

        #expect(viewModel.searchResults.map(\.id) == ["song-1", "song-2", "song-3", "song-4", "song-5"])
        #expect(catalogService.searchRequests.map(\.page.offset) == [0, 25])
    }

    @Test func scrollingAwayFromBottomDoesNotRequestNextPage() async {
        let catalogService = HomeCatalogServiceFake()
        let firstPage = PageRequest(limit: 25, offset: 0)
        catalogService.pages[0] = PagedResult(
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
        let viewModel = HomeViewModel(catalogService: catalogService)

        await viewModel.search(term: "madonna")
        await viewModel.loadNextPageIfNeeded(currentSongID: "song-1")

        #expect(catalogService.searchRequests.map(\.page.offset) == [0])
    }

    @Test func failedSearchShowsErrorState() async {
        let catalogService = HomeCatalogServiceFake()
        catalogService.error = MusicCatalogError.songNotFound("missing")
        let viewModel = HomeViewModel(catalogService: catalogService)

        await viewModel.search(term: "missing")

        #expect(viewModel.state == .error("We could not load songs for this search."))
        #expect(viewModel.searchResults.isEmpty)
    }

    @Test func recentStoreFailureShowsOfflineState() async {
        let viewModel = HomeViewModel(
            catalogService: HomeCatalogServiceFake(),
            recentSongsStore: HomeRecentSongsStoreFake(error: MusicCatalogError.emptySearchTerm)
        )

        await viewModel.loadRecentSongs()

        #expect(viewModel.state == .offline("Recent songs are unavailable offline on this device."))
        #expect(viewModel.recentSongs.isEmpty)
    }
}

@MainActor
private final class HomeCatalogServiceFake: MusicCatalogServicing {
    struct SearchRequest {
        let term: String
        let page: PageRequest
    }

    var pages: [Int: PagedResult<Song>] = [:]
    var error: Error?
    private(set) var searchRequests: [SearchRequest] = []

    func searchSongs(term: String, page: PageRequest) async throws -> PagedResult<Song> {
        searchRequests.append(SearchRequest(term: term, page: page))

        if let error {
            throw error
        }

        return pages[page.offset] ?? PagedResult(items: [], page: page, nextPage: nil)
    }

    func song(id: Song.ID) async throws -> Song {
        sampleHomeSong(id: id)
    }
}

@MainActor
private final class HomeRecentSongsStoreFake: RecentSongsStoring {
    var recentSongs: [Song]
    var error: Error?

    init(recentSongs: [Song] = [], error: Error? = nil) {
        self.recentSongs = recentSongs
        self.error = error
    }

    func saveRecentlyPlayed(_ song: Song, playedAt: Date) async throws {}

    func saveViewedSong(_ song: Song, viewedAt: Date) async throws {}

    func saveViewedAlbum(_ album: Album, viewedAt: Date) async throws {}

    func recentlyPlayed(limit: Int) async throws -> [Song] {
        if let error {
            throw error
        }

        return Array(recentSongs.prefix(limit))
    }

    func cachedSong(id: Song.ID) async throws -> Song? {
        recentSongs.first { $0.id == id }
    }

    func cachedAlbum(id: Album.ID) async throws -> Album? {
        nil
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
