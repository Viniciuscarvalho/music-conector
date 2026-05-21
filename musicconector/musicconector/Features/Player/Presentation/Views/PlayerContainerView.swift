//
//  PlayerContainerView.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import SwiftData
import SwiftUI

struct PlayerContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.playerDependencies) private var playerDependencies
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: PlayerViewModel?

    let song: Song
    let showsBackButton: Bool
    let onMoreOptions: (Song) -> Void

    init(song: Song, showsBackButton: Bool = true, onMoreOptions: @escaping (Song) -> Void = { _ in }) {
        self.song = song
        self.showsBackButton = showsBackButton
        self.onMoreOptions = onMoreOptions
    }

    var body: some View {
        Group {
            if let viewModel {
                PlayerScreen(
                    song: song,
                    viewModel: viewModel,
                    showsBackButton: showsBackButton,
                    onBack: { dismiss() },
                    onMoreOptions: { onMoreOptions(song) }
                )
            } else {
                LoadingPlayerView()
            }
        }
        .task(id: song.id) {
            if viewModel?.songID != song.id {
                viewModel = PlayerViewModel(
                    song: song,
                    repository: playerDependencies.makeRepository(modelContext)
                )
            }

            await viewModel?.load()
            if viewModel?.state == .ready {
                viewModel?.startProgressUpdates()
            }
        }
        .onDisappear {
            viewModel?.stopProgressUpdates()
        }
    }
}

private struct LoadingPlayerView: View {
    var body: some View {
        ZStack {
            MCColor.background
                .ignoresSafeArea()

            MCLoadingStateView(title: "Loading player")
        }
    }
}
