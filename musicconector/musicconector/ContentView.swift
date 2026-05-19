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

    var body: some View {
        NavigationStack {
            ZStack {
                MusicConectorColor.background
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 24) {
                    FoundationHeaderView()

                    if recentSongs.isEmpty {
                        EmptyFoundationStateView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        RecentSongsPreviewList(songs: recentSongs)
                    }

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
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
        VStack(alignment: .leading, spacing: 8) {
            Text("MusicConector")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(MusicConectorColor.primaryText)

            Text("Apple Music search and playback foundation")
                .font(.subheadline)
                .foregroundStyle(MusicConectorColor.secondaryText)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct EmptyFoundationStateView: View {
    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "music.note")
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(MusicConectorColor.accent)
                .frame(width: 96, height: 96)
                .background(MusicConectorColor.surface, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                .accessibilityHidden(true)

            VStack(spacing: 6) {
                Text("Ready for Apple Music")
                    .font(.headline)
                    .foregroundStyle(MusicConectorColor.primaryText)

                Text("Search, playback, and offline recents will build on this SwiftUI and SwiftData foundation.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(MusicConectorColor.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 24)
        .accessibilityElement(children: .combine)
    }
}

private struct RecentSongsPreviewList: View {
    let songs: [CachedSong]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recently played")
                .font(.headline)
                .foregroundStyle(MusicConectorColor.primaryText)

            ForEach(songs) { song in
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(MusicConectorColor.surface)
                        .frame(width: 48, height: 48)
                        .overlay {
                            Image(systemName: "music.note")
                                .foregroundStyle(MusicConectorColor.accent)
                        }
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(song.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(MusicConectorColor.primaryText)
                            .lineLimit(1)

                        Text(song.artistName)
                            .font(.caption)
                            .foregroundStyle(MusicConectorColor.secondaryText)
                            .lineLimit(1)
                    }

                    Spacer()
                }
            }
        }
    }
}

enum MusicConectorColor {
    static let background = Color.black
    static let surface = Color.white.opacity(0.10)
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.62)
    static let accent = Color(red: 0.12, green: 0.74, blue: 0.82)
}


#Preview {
    ContentView()
        .modelContainer(for: CachedSong.self, inMemory: true)
}
