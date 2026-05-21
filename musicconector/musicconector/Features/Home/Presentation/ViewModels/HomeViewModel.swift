//
//  HomeViewModel.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    enum State: Equatable {
        case recents
        case loading
        case results
        case empty
        case error(String)
        case offline(String)
    }

    var searchText = ""
    private(set) var state: State = .recents
    private(set) var recentSongs: [Song] = []
    private(set) var searchResults: [Song] = []
    private(set) var isLoadingNextPage = false
    private(set) var paginationErrorMessage: String?

    private let repository: any HomeSongRepository
    private var currentSearchTerm = ""
    private var nextPage: PageRequest?

    init(repository: any HomeSongRepository) {
        self.repository = repository
    }

    var isSearchActive: Bool {
        !currentSearchTerm.isEmpty || !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var songs: [Song] {
        isSearchActive ? searchResults : recentSongs
    }

    func loadRecentSongs(limit: Int = 10) async {
        do {
            recentSongs = try await repository.recentSongs(limit: limit)
            if !isSearchActive {
                state = .recents
            }
        } catch {
            recentSongs = []
            if !isSearchActive {
                state = .offline(Self.message(forRecentSongsError: error))
            }
        }
    }

    func search(term rawTerm: String, page: PageRequest = PageRequest()) async {
        let term = rawTerm.trimmingCharacters(in: .whitespacesAndNewlines)
        searchText = rawTerm
        paginationErrorMessage = nil

        guard !term.isEmpty else {
            clearSearch()
            await loadRecentSongs()
            return
        }

        currentSearchTerm = term
        state = .loading

        do {
            let result = try await repository.searchSongs(term: term, page: page)
            guard currentSearchTerm == term else { return }

            searchResults = result.items
            nextPage = result.nextPage
            state = result.items.isEmpty ? .empty : .results
        } catch {
            guard currentSearchTerm == term else { return }

            searchResults = []
            nextPage = nil
            state = .error(Self.message(forSearchError: error))
        }
    }

    func clearSearch() {
        searchText = ""
        currentSearchTerm = ""
        searchResults = []
        nextPage = nil
        paginationErrorMessage = nil
        state = .recents
    }

    func loadNextPageIfNeeded(currentSongID: Song.ID?) async {
        guard
            state == .results,
            !isLoadingNextPage,
            let nextPage,
            shouldLoadNextPage(currentSongID: currentSongID)
        else {
            return
        }

        isLoadingNextPage = true
        paginationErrorMessage = nil
        defer { isLoadingNextPage = false }

        do {
            let result = try await repository.searchSongs(term: currentSearchTerm, page: nextPage)
            let existingIDs = Set(searchResults.map(\.id))
            let newSongs = result.items.filter { !existingIDs.contains($0.id) }
            searchResults.append(contentsOf: newSongs)
            self.nextPage = result.nextPage
        } catch {
            paginationErrorMessage = Self.message(forPaginationError: error)
        }
    }

    func albumID(for song: Song) async throws -> Album.ID {
        try await repository.albumID(for: song)
    }

    private func shouldLoadNextPage(currentSongID: Song.ID?) -> Bool {
        guard let currentSongID else { return true }
        guard let currentIndex = searchResults.firstIndex(where: { $0.id == currentSongID }) else {
            return false
        }

        let thresholdIndex = max(searchResults.startIndex, searchResults.count - 3)
        return currentIndex >= thresholdIndex
    }

    private static func message(forSearchError error: Error) -> String {
        if error.isConnectionUnavailable {
            return "Check your internet connection and try again."
        }

        if case MusicCatalogError.invalidCatalogData = error {
            return "Some song data could not be loaded correctly. Try again in a moment."
        }

        if error.isAuthorizationUnavailable {
            return "Apple Music access is unavailable. Check MusicKit permissions and try again."
        }

        return "We could not load songs for this search. Try again."
    }

    private static func message(forPaginationError error: Error) -> String {
        if error.isConnectionUnavailable {
            return "No internet connection. Pull back and try again."
        }

        if case MusicCatalogError.invalidCatalogData = error {
            return "More songs could not be displayed because some data was incomplete."
        }

        return "We could not load more songs."
    }

    private static func message(forRecentSongsError error: Error) -> String {
        if error.isConnectionUnavailable {
            return "No internet connection, and recent songs are unavailable on this device."
        }

        return "Recent songs are unavailable on this device."
    }
}
