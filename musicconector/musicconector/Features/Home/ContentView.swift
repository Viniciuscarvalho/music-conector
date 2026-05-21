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
    @State private var selectedDetail: HomeDetail?
    @State private var navigationPath: [HomeRoute] = []
    @State private var moreOptionsSong: Song?

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
                    onSelectSong: { selectedDetail = .player($0) },
                    onMoreSong: { moreOptionsSong = $0 }
                )
                .navigationTitle("")
                .toolbar(.hidden, for: .navigationBar)
            } detail: {
                switch selectedDetail {
                case .player(let selectedSong):
                    PlayerContainerView(song: selectedSong, showsBackButton: false)
                case .album(let albumID):
                    AlbumContainerView(albumID: albumID, showsBackButton: false) { track in
                        selectedDetail = .player(track)
                    }
                case nil:
                    HomeSelectionDetail(song: nil)
                }
            }
            .sheet(item: $moreOptionsSong) { song in
                MoreOptionsSheet(song: song) { albumID in
                    moreOptionsSong = nil
                    selectedDetail = .album(albumID)
                }
            }
        } else {
            NavigationStack(path: $navigationPath) {
                HomeSongsScreen(
                    viewModel: viewModel,
                    selectedSong: selectedSong,
                    onSelectSong: { navigationPath.append(.player($0)) },
                    onMoreSong: { moreOptionsSong = $0 }
                )
                .navigationTitle("")
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: HomeRoute.self) { route in
                    switch route {
                    case .player(let song):
                        PlayerContainerView(song: song)
                    case .album(let albumID):
                        AlbumContainerView(albumID: albumID) { track in
                            navigationPath.append(.player(track))
                        }
                    }
                }
            }
            .sheet(item: $moreOptionsSong) { song in
                MoreOptionsSheet(song: song) { albumID in
                    moreOptionsSong = nil
                    navigationPath.append(.album(albumID))
                }
            }
        }
    }

    private var selectedSong: Song? {
        guard case .player(let song) = selectedDetail else { return nil }
        return song
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
