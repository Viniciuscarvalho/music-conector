//
//  AlbumContainerView.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 21/05/26.
//

import SwiftData
import SwiftUI

struct AlbumContainerView: View {
    @Environment(\.albumDependencies) private var albumDependencies
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: AlbumViewModel?

    let albumID: Album.ID
    let showsBackButton: Bool
    let onSelectTrack: (Song) -> Void

    init(albumID: Album.ID, showsBackButton: Bool = true, onSelectTrack: @escaping (Song) -> Void) {
        self.albumID = albumID
        self.showsBackButton = showsBackButton
        self.onSelectTrack = onSelectTrack
    }

    var body: some View {
        Group {
            if let viewModel {
                AlbumScreen(
                    viewModel: viewModel,
                    showsBackButton: showsBackButton,
                    onBack: { dismiss() },
                    onSelectTrack: onSelectTrack
                )
            } else {
                LoadingAlbumView()
            }
        }
        .task(id: albumID) {
            if viewModel?.albumID != albumID {
                viewModel = AlbumViewModel(
                    albumID: albumID,
                    repository: albumDependencies.makeRepository(modelContext)
                )
            }

            await viewModel?.load()
        }
    }
}

private struct LoadingAlbumView: View {
    var body: some View {
        ZStack {
            MCColor.background
                .ignoresSafeArea()

            MCLoadingStateView(title: "Loading album")
        }
    }
}
