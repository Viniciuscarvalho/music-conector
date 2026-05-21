//
//  HomeSongsScreen.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import SwiftUI

struct HomeSongsScreen: View {
    @Bindable var viewModel: HomeViewModel
    let selectedSong: Song?
    let onSelectSong: (Song) -> Void
    let onMoreSong: (Song) -> Void
    @State private var isSearchInputExpanded = true

    var body: some View {
        ZStack {
            MCColor.background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: MCSpacing.xLarge) {
                header

                HomeContentStateView(
                    viewModel: viewModel,
                    selectedSong: selectedSong,
                    onSelectSong: onSelectSong,
                    onMoreSong: onMoreSong
                )

                Spacer(minLength: 0)
            }
            .padding(.horizontal, MCSpacing.screenHorizontal)
            .padding(.top, MCSpacing.xxLarge)
            .padding(.bottom, 12)
            .frame(maxWidth: 560, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .task(id: viewModel.searchText) {
            await searchTextDidChange()
        }
    }

    @ViewBuilder
    private var header: some View {
        if viewModel.isSearchActive && !isSearchInputExpanded {
            CompactSearchHeader {
                isSearchInputExpanded = true
            }
        } else {
            FoundationHeaderView()

            MCSearchField(text: $viewModel.searchText) {
                if viewModel.isSearchActive {
                    isSearchInputExpanded = false
                }
            }
        }
    }

    private func searchTextDidChange() async {
        let term = viewModel.searchText
        guard !term.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            viewModel.clearSearch()
            isSearchInputExpanded = true
            await viewModel.loadRecentSongs()
            return
        }

        do {
            try await Task.sleep(for: .milliseconds(350))
        } catch {
            return
        }

        guard !Task.isCancelled else { return }
        await viewModel.search(term: term)
    }
}

private struct FoundationHeaderView: View {
    var body: some View {
        HStack {
            Text("Songs")
                .font(MCTypography.screenTitle)
                .foregroundStyle(MCColor.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            Spacer(minLength: 0)
        }
    }
}

private struct CompactSearchHeader: View {
    let onSearch: () -> Void

    var body: some View {
        ZStack {
            HStack {
                MCCircularIconButton(systemName: "magnifyingglass", accessibilityLabel: "Search", action: onSearch)

                Spacer(minLength: 0)
            }

            Text("Songs")
                .font(MCTypography.navigationTitle)
                .foregroundStyle(MCColor.primaryText)
        }
        .frame(minHeight: MCControlSize.navigationButton)
    }
}
