//
//  AlbumScreen.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 21/05/26.
//

import SwiftUI

struct AlbumScreen: View {
    @Bindable var viewModel: AlbumViewModel
    let showsBackButton: Bool
    let onBack: () -> Void
    let onSelectTrack: (Song) -> Void

    var body: some View {
        ZStack {
            MCColor.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                AlbumNavigationBar(showsBackButton: showsBackButton, onBack: onBack)

                switch viewModel.state {
                case .loading:
                    MCLoadingStateView(title: "Loading album")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .error(let message):
                    MCStateView(
                        symbolName: "rectangle.stack.badge.exclamationmark",
                        title: "Album unavailable",
                        message: message,
                        actionTitle: "Retry"
                    ) {
                        Task {
                            await viewModel.load()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .empty, .loaded:
                    AlbumContent(
                        album: viewModel.album,
                        tracks: viewModel.tracks,
                        message: viewModel.message,
                        isEmpty: viewModel.state == .empty,
                        onSelectTrack: onSelectTrack
                    )
                }
            }
            .padding(.horizontal, MCSpacing.screenHorizontal)
            .padding(.top, MCSpacing.large)
            .padding(.bottom, MCSpacing.xxLarge)
            .frame(maxWidth: 560)
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct AlbumNavigationBar: View {
    let showsBackButton: Bool
    let onBack: () -> Void

    var body: some View {
        HStack {
            if showsBackButton {
                MCCircularIconButton(systemName: "chevron.left", accessibilityLabel: "Back", action: onBack)
            } else {
                Color.clear
                    .frame(width: MCControlSize.navigationButton, height: MCControlSize.navigationButton)
            }

            Spacer(minLength: 0)
        }
        .frame(height: MCControlSize.navigationButton)
    }
}

private struct AlbumContent: View {
    let album: Album?
    let tracks: [Song]
    let message: String?
    let isEmpty: Bool
    let onSelectTrack: (Song) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: MCSpacing.xLarge) {
                if let album {
                    AlbumHeader(album: album)
                }

                if let message {
                    Text(message)
                        .font(MCTypography.songSubtitle)
                        .foregroundStyle(MCColor.secondaryText)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityLabel(message)
                }

                if isEmpty {
                    MCStateView(
                        symbolName: "music.note.list",
                        title: "No tracks",
                        message: "Tracks are unavailable for this album."
                    )
                    .padding(.top, MCSpacing.xxLarge)
                } else {
                    LazyVStack(spacing: MCSpacing.large) {
                        ForEach(tracks) { track in
                            MCSongRow(
                                content: MCSongRowContent(
                                    id: track.id,
                                    title: track.title,
                                    subtitle: track.artist.name,
                                    artworkURL: track.artworkURL
                                ),
                                showsMoreButton: false,
                                onTap: { onSelectTrack(track) }
                            )
                        }
                    }
                    .padding(.top, MCSpacing.large)
                }
            }
            .padding(.top, MCSpacing.medium)
        }
        .scrollIndicators(.hidden)
    }
}

private struct AlbumHeader: View {
    let album: Album

    var body: some View {
        VStack(spacing: MCSpacing.medium) {
            MCArtwork(
                url: album.artworkURL,
                size: MCArtworkSize.albumHeader,
                cornerRadius: MCRadius.largeArtwork
            )

            VStack(spacing: MCSpacing.xSmall) {
                Text(album.title)
                    .font(MCTypography.navigationTitle)
                    .foregroundStyle(MCColor.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.82)

                Text(album.artist.name)
                    .font(MCTypography.body)
                    .foregroundStyle(MCColor.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    AlbumScreen(
        viewModel: AlbumViewModel(
            albumID: "random-access-memories",
            repository: PreviewAlbumRepository()
        ),
        showsBackButton: true,
        onBack: {},
        onSelectTrack: { _ in }
    )
}

@MainActor
private final class PreviewAlbumRepository: AlbumRepository {
    func cachedAlbum(id: Album.ID) async throws -> Album? { nil }

    func fetchAlbum(id: Album.ID) async throws -> Album {
        Album(
            id: id,
            title: "Album Title",
            artist: Artist(id: "daft-punk", name: "Daft Punk"),
            artworkURL: URL(string: "https://example.com/album.jpg"),
            tracks: [
                Song(id: "around-the-world", title: "Around the World", artist: Artist(id: "daft-punk", name: "Daft Punk")),
                Song(id: "get-lucky", title: "Get Lucky", artist: Artist(id: "daft-punk", name: "Daft Punk feat. Pharrell Williams"))
            ]
        )
    }

    func saveViewedAlbum(_ album: Album) async throws {}
}
