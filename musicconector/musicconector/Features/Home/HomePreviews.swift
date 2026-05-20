//
//  HomePreviews.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import SwiftData
import SwiftUI

private struct DesignSystemFoundationPreview: View {
    @State private var isPlaying = false

    var body: some View {
        VStack(alignment: .leading, spacing: MCSpacing.xLarge) {
            Text("Recently played")
                .font(MCTypography.navigationTitle)
                .foregroundStyle(MCColor.primaryText)

            MCSongRow(
                content: MCSongRowContent(
                    id: "get-lucky",
                    title: "Get Lucky",
                    subtitle: "Daft Punk feat. Pharrell Williams"
                )
            )

            MCPlayerControls(isPlaying: isPlaying, onPlayPause: {
                isPlaying.toggle()
            })

            MCMoreOptionsSheetSurface(title: "Song name", subtitle: "Artist name") {
                MCMoreOptionsActionRow(systemName: "music.note.list", title: "View album") {}
            }
        }
        .padding()
        .background(MCColor.background)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [CachedAlbum.self, CachedSong.self, RecentPlay.self], inMemory: true)
}

#Preview("Design System") {
    DesignSystemFoundationPreview()
}
