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
