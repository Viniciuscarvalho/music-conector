//
//  MoreOptionsSheet.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 21/05/26.
//

import SwiftUI

struct MoreOptionsSheet: View {
    let song: Song
    let isResolvingAlbum: Bool
    let albumErrorMessage: String?
    let onViewAlbum: () -> Void

    init(
        song: Song,
        isResolvingAlbum: Bool = false,
        albumErrorMessage: String? = nil,
        onViewAlbum: @escaping () -> Void
    ) {
        self.song = song
        self.isResolvingAlbum = isResolvingAlbum
        self.albumErrorMessage = albumErrorMessage
        self.onViewAlbum = onViewAlbum
    }

    var body: some View {
        MCMoreOptionsSheetSurface(title: song.title, subtitle: song.artist.name) {
            MCMoreOptionsActionRow(systemName: "music.note.list", title: "View album") {
                onViewAlbum()
            }
            .disabled(!song.canResolveAlbum || isResolvingAlbum)
            .opacity(!song.canResolveAlbum ? 0.44 : 1)
            .accessibilityHint(song.canResolveAlbum ? "Opens the album." : "Album metadata is unavailable for this song.")

            if isResolvingAlbum {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(MCColor.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityLabel("Loading album")
            }

            if let albumErrorMessage {
                Text(albumErrorMessage)
                    .font(MCTypography.songSubtitle)
                    .foregroundStyle(MCColor.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, MCSpacing.small)
        .padding(.bottom, MCSpacing.medium)
        .presentationDetents([.height(albumErrorMessage == nil ? 150 : 194)])
        .presentationDragIndicator(.visible)
        .accessibilityIdentifier("more-options-sheet")
    }
}
