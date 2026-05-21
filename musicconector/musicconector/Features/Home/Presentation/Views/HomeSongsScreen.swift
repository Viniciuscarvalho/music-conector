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
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        ZStack {
            MCColor.background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: MCSpacing.xLarge) {
                header

                HomeContentStateView(
                    viewModel: viewModel,
                    selectedSong: selectedSong,
                    onSelectSong: { song in
                        isSearchFocused = false
                        onSelectSong(song)
                    },
                    onMoreSong: { song in
                        isSearchFocused = false
                        onMoreSong(song)
                    }
                )
                .contentShape(Rectangle())
                .simultaneousGesture(
                    TapGesture().onEnded {
                        isSearchFocused = false
                    }
                )
                .transition(.mcContent)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, MCSpacing.screenHorizontal)
            .padding(.top, MCSpacing.xxLarge)
            .padding(.bottom, 12)
            .frame(maxWidth: 560, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .animation(MCAnimation.standard, value: viewModel.state)
        .animation(MCAnimation.quick, value: isSearchInputExpanded)
        .task(id: viewModel.searchText) {
            await searchTextDidChange()
        }
    }

    @ViewBuilder
    private var header: some View {
        if viewModel.isSearchActive && !isSearchInputExpanded {
            CompactSearchHeader {
                withAnimation(MCAnimation.standard) {
                    isSearchInputExpanded = true
                    isSearchFocused = true
                }
            }
            .transition(.opacity.combined(with: .move(edge: .top)))
        } else {
            FoundationHeaderView()
                .transition(.opacity.combined(with: .move(edge: .top)))

            MCSearchField(text: $viewModel.searchText, isFocused: $isSearchFocused) {
                if viewModel.isSearchActive {
                    withAnimation(MCAnimation.standard) {
                        isSearchInputExpanded = false
                        isSearchFocused = false
                    }
                }
            }
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    private func searchTextDidChange() async {
        let term = viewModel.searchText
        guard !term.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            viewModel.clearSearch()
            withAnimation(MCAnimation.standard) {
                isSearchInputExpanded = true
            }
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
