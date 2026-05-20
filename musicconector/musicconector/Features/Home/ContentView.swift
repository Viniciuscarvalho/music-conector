//
//  ContentView.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.homeDependencies) private var homeDependencies
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: HomeViewModel?
    @State private var selectedSong: Song?

    init(viewModel: HomeViewModel? = nil) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            if let viewModel {
                homeRoot(viewModel: viewModel)
            } else {
                LoadingHomeBootstrapView()
            }
        }
        .task {
            if viewModel == nil {
                viewModel = HomeViewModel(repository: homeDependencies.makeRepository(modelContext))
            }

            guard let viewModel else { return }
            await viewModel.loadRecentSongs()
        }
    }

    @ViewBuilder
    private func homeRoot(viewModel: HomeViewModel) -> some View {
        if horizontalSizeClass == .regular {
            NavigationSplitView {
                HomeSongsScreen(
                    viewModel: viewModel,
                    selectedSong: selectedSong,
                    onSelectSong: { selectedSong = $0 }
                )
                .navigationTitle("")
                .toolbar(.hidden, for: .navigationBar)
            } detail: {
                HomeSelectionDetail(song: selectedSong)
            }
        } else {
            NavigationStack {
                HomeSongsScreen(
                    viewModel: viewModel,
                    selectedSong: selectedSong,
                    onSelectSong: { selectedSong = $0 }
                )
                .navigationTitle("")
                .toolbar(.hidden, for: .navigationBar)
            }
        }
    }
}

private struct LoadingHomeBootstrapView: View {
    var body: some View {
        ZStack {
            MCColor.background
                .ignoresSafeArea()

            LoadingStateView()
        }
    }
}

private struct HomeSongsScreen: View {
    @Bindable var viewModel: HomeViewModel
    let selectedSong: Song?
    let onSelectSong: (Song) -> Void
    @State private var isSearchInputExpanded = true

    var body: some View {
        ZStack {
            MCColor.background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: MCSpacing.xLarge) {
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

                HomeContentStateView(
                    viewModel: viewModel,
                    selectedSong: selectedSong,
                    onSelectSong: onSelectSong
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

private struct HomeContentStateView: View {
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

private struct HomeSongList: View {
    let title: String?
    let songs: [Song]
    let selectedSongID: Song.ID?
    let isLoadingNextPage: Bool
    let paginationErrorMessage: String?
    let onSelectSong: (Song) -> Void
    let onMore: (Song) -> Void
    let onSongAppeared: (Song) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: MCSpacing.large) {
                if let title {
                    Text(title)
                        .font(MCTypography.navigationTitle)
                        .foregroundStyle(MCColor.primaryText)
                }

                ForEach(songs) { song in
                    MCSongRow(
                        content: MCSongRowContent(song: song),
                        onTap: { onSelectSong(song) },
                        onMore: { onMore(song) }
                    )
                    .padding(.vertical, selectedSongID == song.id ? MCSpacing.xSmall : 0)
                    .background(selectionBackground(for: song), in: RoundedRectangle(cornerRadius: MCRadius.searchField, style: .continuous))
                    .onAppear {
                        onSongAppeared(song)
                    }
                }

                if isLoadingNextPage {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(MCColor.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, MCSpacing.large)
                        .accessibilityLabel("Loading more songs")
                }

                if let paginationErrorMessage {
                    Text(paginationErrorMessage)
                        .font(MCTypography.songSubtitle)
                        .foregroundStyle(MCColor.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, MCSpacing.medium)
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    private func selectionBackground(for song: Song) -> Color {
        selectedSongID == song.id ? MCColor.surface.opacity(0.72) : .clear
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

private struct HomeSelectionDetail: View {
    let song: Song?

    var body: some View {
        ZStack {
            MCColor.background
                .ignoresSafeArea()

            if let song {
                VStack(spacing: MCSpacing.large) {
                    MCArtwork(url: song.artworkURL, size: 180, cornerRadius: MCRadius.largeArtwork)

                    VStack(spacing: MCSpacing.xSmall) {
                        Text(song.title)
                            .font(MCTypography.screenTitle)
                            .foregroundStyle(MCColor.primaryText)
                            .multilineTextAlignment(.center)

                        Text(song.artist.name)
                            .font(MCTypography.body)
                            .foregroundStyle(MCColor.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(MCSpacing.xxLarge)
                .accessibilityElement(children: .combine)
            } else {
                Text("Select a song")
                    .font(MCTypography.navigationTitle)
                    .foregroundStyle(MCColor.secondaryText)
            }
        }
    }
}

private extension MCSongRowContent {
    init(song: Song) {
        self.init(
            id: song.id,
            title: song.title,
            subtitle: song.artist.name,
            artworkURL: song.artworkURL
        )
    }
}

private struct DesignSystemFoundationPreview: View {
    @State private var isPlaying = false

    var body: some View {
        VStack(alignment: .leading, spacing: MCSpacing.xLarge) {
            Text("Recently played")
                .font(MCTypography.navigationTitle)
                .foregroundStyle(MCColor.primaryText)

            MCSongRow(
                content: MCSongRowContent(
                    id: "get-lucky",
                    title: "Get Lucky",
                    subtitle: "Daft Punk feat. Pharrell Williams"
                )
            )

            MCPlayerControls(isPlaying: isPlaying, onPlayPause: {
                isPlaying.toggle()
            })

            MCMoreOptionsSheetSurface(title: "Song name", subtitle: "Artist name") {
                MCMoreOptionsActionRow(systemName: "music.note.list", title: "View album") {}
            }
        }
        .padding()
        .background(MCColor.background)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [CachedAlbum.self, CachedSong.self, RecentPlay.self], inMemory: true)
}

#Preview("Design System") {
    DesignSystemFoundationPreview()
}
