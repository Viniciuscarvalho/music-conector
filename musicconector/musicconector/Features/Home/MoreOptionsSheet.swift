//
//  MoreOptionsSheet.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 21/05/26.
//

import SwiftUI

struct MoreOptionsSheet: View {
    let song: Song
    let onViewAlbum: (Album.ID) -> Void

    var body: some View {
        MCMoreOptionsSheetSurface(title: song.title, subtitle: song.artist.name) {
            MCMoreOptionsActionRow(systemName: "music.note.list", title: "View album") {
                guard let albumID = song.albumID else { return }
                onViewAlbum(albumID)
            }
            .disabled(song.albumID == nil)
            .opacity(song.albumID == nil ? 0.44 : 1)
            .accessibilityHint(song.albumID == nil ? "Album metadata is unavailable for this song." : "Opens the album.")
        }
        .padding(.horizontal, MCSpacing.screenHorizontal)
        .padding(.bottom, MCSpacing.medium)
        .presentationDetents([.height(168)])
        .presentationDragIndicator(.visible)
    }
}
