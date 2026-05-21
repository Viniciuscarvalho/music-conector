//
//  HomeContentStateView.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import SwiftUI

struct HomeContentStateView: View {
    @Bindable var viewModel: HomeViewModel
    let selectedSong: Song?
    let onSelectSong: (Song) -> Void

    var body: some View {
        switch viewModel.state {
        case .recents where viewModel.recentSongs.isEmpty:
            MCStateView(
                symbolName: "music.note.list",
                title: "No recent songs",
                message: "Search for a song to start building your library."
            )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loading:
            MCLoadingStateView(title: "Loading songs")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .empty:
            MCStateView(
                symbolName: "magnifyingglass",
                title: "No songs found",
                message: "Try another search term."
            )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .error(let message):
            MCStateView(
                symbolName: "wifi.exclamationmark",
                title: "Search unavailable",
                message: message,
                actionTitle: "Retry"
            ) {
                Task {
                    await viewModel.search(term: viewModel.searchText)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .offline(let message):
            MCStateView(
                symbolName: "externaldrive.badge.exclamationmark",
                title: "Recent songs unavailable",
                message: message,
                actionTitle: "Retry"
            ) {
                Task {
                    await viewModel.loadRecentSongs()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .recents, .results:
            HomeSongList(
                title: viewModel.isSearchActive ? nil : "Recently played",
                songs: viewModel.songs,
                selectedSongID: selectedSong?.id,
                isLoadingNextPage: viewModel.isLoadingNextPage,
                paginationErrorMessage: viewModel.paginationErrorMessage,
                onSelectSong: onSelectSong,
                onMore: { _ in },
                onSongAppeared: { song in
                    Task {
                        await viewModel.loadNextPageIfNeeded(currentSongID: song.id)
                    }
                }
            )
        }
    }
}

struct LoadingHomeBootstrapView: View {
    var body: some View {
        ZStack {
            MCColor.background
                .ignoresSafeArea()

            MCLoadingStateView(title: "Loading songs")
        }
    }
}
