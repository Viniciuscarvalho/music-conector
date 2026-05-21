//
//  HomeSongList.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import SwiftUI

struct HomeSongList: View {
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
                        content: rowContent(for: song),
                        onTap: { onSelectSong(song) },
                        onMore: { onMore(song) }
                    )
                    .padding(.vertical, selectedSongID == song.id ? MCSpacing.xSmall : 0)
                    .background(
                        selectionBackground(for: song),
                        in: RoundedRectangle(cornerRadius: MCRadius.searchField, style: .continuous)
                    )
                    .transition(.mcRow)
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
        .scrollDismissesKeyboard(.interactively)
        .animation(MCAnimation.standard, value: songs.map(\.id))
        .animation(MCAnimation.quick, value: selectedSongID)
    }

    private func selectionBackground(for song: Song) -> Color {
        selectedSongID == song.id ? MCColor.surface.opacity(0.72) : .clear
    }

    private func rowContent(for song: Song) -> MCSongRowContent {
        MCSongRowContent(
            id: song.id,
            title: song.title,
            subtitle: song.artist.name,
            artworkURL: song.artworkURL
        )
    }
}
