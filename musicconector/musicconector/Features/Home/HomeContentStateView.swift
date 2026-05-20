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
            EmptyFoundationStateView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loading:
            LoadingStateView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .empty:
            EmptySearchStateView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .error(let message):
            HomeMessageStateView(title: "Search unavailable", message: message) {
                Task {
                    await viewModel.search(term: viewModel.searchText)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .offline(let message):
            HomeMessageStateView(title: "Offline cache unavailable", message: message) {
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

            LoadingStateView()
        }
    }
}

private struct EmptyFoundationStateView: View {
    var body: some View {
        VStack(spacing: MCSpacing.large) {
            MCArtwork(url: nil, size: 96, cornerRadius: MCRadius.largeArtwork)

            VStack(spacing: MCSpacing.xSmall) {
                Text("No recent songs")
                    .font(MCTypography.navigationTitle)
                    .foregroundStyle(MCColor.primaryText)

                Text("Search for a song to start building your library.")
                    .font(MCTypography.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(MCColor.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, MCSpacing.xxLarge)
        .accessibilityElement(children: .combine)
    }
}

private struct EmptySearchStateView: View {
    var body: some View {
        VStack(spacing: MCSpacing.large) {
            MCArtwork(url: nil, size: 96, cornerRadius: MCRadius.largeArtwork)

            VStack(spacing: MCSpacing.xSmall) {
                Text("No songs found")
                    .font(MCTypography.navigationTitle)
                    .foregroundStyle(MCColor.primaryText)

                Text("Try another search term.")
                    .font(MCTypography.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(MCColor.secondaryText)
            }
        }
        .padding(.horizontal, MCSpacing.xxLarge)
        .accessibilityElement(children: .combine)
    }
}

private struct LoadingStateView: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(MCColor.primaryText)
            .accessibilityLabel("Loading songs")
    }
}

private struct HomeMessageStateView: View {
    let title: String
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: MCSpacing.large) {
            VStack(spacing: MCSpacing.xSmall) {
                Text(title)
                    .font(MCTypography.navigationTitle)
                    .foregroundStyle(MCColor.primaryText)

                Text(message)
                    .font(MCTypography.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(MCColor.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button("Retry", action: retry)
                .font(MCTypography.body)
                .foregroundStyle(MCColor.primaryText)
                .padding(.horizontal, MCSpacing.large)
                .frame(minHeight: MCControlSize.searchHeight)
                .background(MCColor.surface, in: RoundedRectangle(cornerRadius: MCRadius.searchField, style: .continuous))
        }
        .padding(.horizontal, MCSpacing.xxLarge)
        .accessibilityElement(children: .contain)
    }
}
