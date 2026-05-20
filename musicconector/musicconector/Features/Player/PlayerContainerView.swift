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

    init(song: Song, showsBackButton: Bool = true) {
        self.song = song
        self.showsBackButton = showsBackButton
    }

    var body: some View {
        Group {
            if let viewModel {
                PlayerScreen(
                    song: song,
                    viewModel: viewModel,
                    showsBackButton: showsBackButton,
                    onBack: { dismiss() }
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
            viewModel?.startProgressUpdates()
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

            ProgressView()
                .progressViewStyle(.circular)
                .tint(MCColor.primaryText)
                .accessibilityLabel("Loading player")
        }
    }
}
