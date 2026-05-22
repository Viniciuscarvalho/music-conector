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
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.homeDependencies) private var homeDependencies
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: HomeViewModel?
    @State private var selectedDetail: HomeDetail?
    @State private var navigationPath: [HomeRoute] = []
    @State private var splitColumnVisibility: NavigationSplitViewVisibility = .all
    @State private var moreOptionsSong: Song?
    @State private var pendingAlbumID: Album.ID?
    @State private var resolvingAlbumSongID: Song.ID?
    @State private var albumNavigationErrorMessage: String?

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
        let layout = HomeAdaptiveLayout(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )

        if layout.usesSplitLayout {
            NavigationSplitView(columnVisibility: $splitColumnVisibility) {
                HomeSongsScreen(
                    viewModel: viewModel,
                    selectedSong: selectedSong,
                    onSelectSong: { song in
                        withAnimation(MCAnimation.standard) {
                            selectedDetail = .player(song)
                        }
                    },
                    onMoreSong: openMoreOptions
                )
                .navigationSplitViewColumnWidth(
                    min: layout.sidebar.minimumWidth,
                    ideal: layout.sidebar.idealWidth,
                    max: layout.sidebar.maximumWidth
                )
                .navigationTitle("")
                .toolbar(.hidden, for: .navigationBar)
            } detail: {
                switch selectedDetail {
                case .player(let selectedSong):
                    PlayerContainerView(
                        song: selectedSong,
                        showsBackButton: false,
                        onMoreOptions: openMoreOptions
                    )
                        .id(selectedSong.id)
                        .transition(.mcContent)
                case .album(let albumID):
                    AlbumContainerView(albumID: albumID, showsBackButton: false) { track in
                        withAnimation(MCAnimation.standard) {
                            selectedDetail = .player(track)
                        }
                    }
                    .transition(.mcContent)
                case nil:
                    HomeSelectionDetail(song: nil)
                        .transition(.mcContent)
                }
            }
            .navigationSplitViewStyle(.balanced)
            .sheet(item: $moreOptionsSong, onDismiss: {
                navigateToPendingAlbum(usingSplitLayout: true)
            }) { song in
                MoreOptionsSheet(
                    song: song,
                    isResolvingAlbum: resolvingAlbumSongID == song.id,
                    albumErrorMessage: albumNavigationErrorMessage
                ) {
                    Task {
                        await resolveAlbum(from: song)
                    }
                }
            }
        } else {
            NavigationStack(path: $navigationPath) {
                HomeSongsScreen(
                    viewModel: viewModel,
                    selectedSong: selectedSong,
                    onSelectSong: { song in
                        withAnimation(MCAnimation.standard) {
                            navigationPath.append(.player(song))
                        }
                    },
                    onMoreSong: openMoreOptions
                )
                .navigationTitle("")
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: HomeRoute.self) { route in
                    switch route {
                    case .player(let song):
                        PlayerContainerView(song: song, onMoreOptions: openMoreOptions)
                            .id(song.id)
                            .transition(.mcContent)
                    case .album(let albumID):
                        AlbumContainerView(albumID: albumID) { track in
                            withAnimation(MCAnimation.standard) {
                                navigationPath.append(.player(track))
                            }
                        }
                        .transition(.mcContent)
                    }
                }
            }
            .sheet(item: $moreOptionsSong, onDismiss: {
                navigateToPendingAlbum(usingSplitLayout: false)
            }) { song in
                MoreOptionsSheet(
                    song: song,
                    isResolvingAlbum: resolvingAlbumSongID == song.id,
                    albumErrorMessage: albumNavigationErrorMessage
                ) {
                    Task {
                        await resolveAlbum(from: song)
                    }
                }
            }
        }
    }

    private func openMoreOptions(for song: Song) {
        withAnimation(MCAnimation.quick) {
            albumNavigationErrorMessage = nil
            moreOptionsSong = song
        }
    }

    private var selectedSong: Song? {
        guard case .player(let song) = selectedDetail else { return nil }
        return song
    }

    private func resolveAlbum(from song: Song) async {
        guard resolvingAlbumSongID == nil else { return }
        albumNavigationErrorMessage = nil

        if let albumID = song.resolvedAlbumID {
            pendingAlbumID = albumID
            moreOptionsSong = nil
            return
        }

        guard let viewModel else {
            albumNavigationErrorMessage = "Album could not be opened right now."
            return
        }

        resolvingAlbumSongID = song.id
        defer { resolvingAlbumSongID = nil }

        do {
            pendingAlbumID = try await viewModel.albumID(for: song)
            moreOptionsSong = nil
        } catch {
            albumNavigationErrorMessage = Self.message(forAlbumNavigationError: error)
        }
    }

    private func navigateToPendingAlbum(usingSplitLayout usesSplitLayout: Bool) {
        guard let albumID = pendingAlbumID else { return }
        pendingAlbumID = nil
        albumNavigationErrorMessage = nil

        withAnimation(MCAnimation.standard) {
            if usesSplitLayout {
                selectedDetail = .album(albumID)
            } else {
                navigationPath.append(.album(albumID))
            }
        }
    }

    private static func message(forAlbumNavigationError error: Error) -> String {
        if error.isConnectionUnavailable {
            return "Check your internet connection and try again."
        }

        if error.isAuthorizationUnavailable {
            return "Apple Music access is unavailable. Check MusicKit permissions and try again."
        }

        return "Album could not be opened."
    }
}

private enum HomeRoute: Hashable {
    case player(Song)
    case album(Album.ID)
}

private enum HomeDetail: Equatable {
    case player(Song)
    case album(Album.ID)
}
