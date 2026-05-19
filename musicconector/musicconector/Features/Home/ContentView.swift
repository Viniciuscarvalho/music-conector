//
//  ContentView.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Query(sort: \CachedSong.lastPlayedAt, order: .reverse)
    private var recentSongs: [CachedSong]
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                MCColor.background
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: MCSpacing.xLarge) {
                    FoundationHeaderView()

                    MCSearchField(text: $searchText)

                    if recentSongs.isEmpty {
                        EmptyFoundationStateView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        RecentSongsPreviewList(
                            songs: recentSongs.map(MCSongRowContent.init(cachedSong:))
                        )
                    }

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, MCSpacing.screenHorizontal)
                .padding(.top, MCSpacing.xxLarge)
                .padding(.bottom, 12)
                .frame(maxWidth: 560, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("")
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

private struct FoundationHeaderView: View {
    var body: some View {
        HStack {
            Text("Songs")
                .font(MCTypography.screenTitle)
                .foregroundStyle(MCColor.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            Spacer(minLength: 0)
        }
    }
}

private struct EmptyFoundationStateView: View {
    var body: some View {
        VStack(spacing: MCSpacing.large) {
            MCArtwork(url: nil, size: 96, cornerRadius: MCRadius.largeArtwork)

            VStack(spacing: MCSpacing.xSmall) {
                Text("No recent songs")
                    .font(MCTypography.navigationTitle)
                    .foregroundStyle(MCColor.primaryText)

                Text("Search for a song to start building your library.")
                    .font(MCTypography.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(MCColor.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, MCSpacing.xxLarge)
        .accessibilityElement(children: .combine)
    }
}

private struct RecentSongsPreviewList: View {
    let songs: [MCSongRowContent]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: MCSpacing.large) {
                Text("Recently played")
                    .font(MCTypography.navigationTitle)
                    .foregroundStyle(MCColor.primaryText)

                ForEach(songs) { song in
                    MCSongRow(content: song)
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}

private extension MCSongRowContent {
    init(cachedSong: CachedSong) {
        self.init(
            id: cachedSong.id,
            title: cachedSong.title,
            subtitle: cachedSong.artistName,
            artworkURL: cachedSong.artworkURL
        )
    }
}

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
        .modelContainer(for: CachedSong.self, inMemory: true)
}

#Preview("Design System") {
    DesignSystemFoundationPreview()
}
