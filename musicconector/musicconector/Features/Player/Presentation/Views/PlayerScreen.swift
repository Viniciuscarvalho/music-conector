//
//  PlayerScreen.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import SwiftUI

struct PlayerScreen: View {
    let song: Song
    @Bindable var viewModel: PlayerViewModel
    let showsBackButton: Bool
    let onBack: () -> Void
    let onMoreOptions: () -> Void

    var body: some View {
        ZStack {
            MCColor.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                PlayerNavigationBar(
                    title: song.albumTitle ?? "Song",
                    showsBackButton: showsBackButton,
                    onBack: onBack,
                    onMoreOptions: onMoreOptions
                )

                switch viewModel.state {
                case .loading:
                    MCLoadingStateView(title: "Loading player")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .error(let message):
                    MCStateView(
                        symbolName: "exclamationmark.triangle",
                        title: "Player unavailable",
                        message: message,
                        actionTitle: "Retry"
                    ) {
                        Task {
                            await viewModel.load()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .ready:
                    PlayerReadyContent(song: song, viewModel: viewModel)
                        .transition(.mcContent)
                }
            }
            .padding(.horizontal, MCSpacing.screenHorizontal)
            .padding(.top, MCSpacing.large)
            .padding(.bottom, MCSpacing.xxLarge)
            .frame(maxWidth: 560)
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .animation(MCAnimation.standard, value: viewModel.state)
        .mcBackSwipeGesture(isEnabled: showsBackButton, action: onBack)
        .accessibilityIdentifier("player-screen")
    }
}

private struct PlayerReadyContent: View {
    let song: Song
    @Bindable var viewModel: PlayerViewModel

    var body: some View {
        Spacer(minLength: 48)

        MCArtwork(
            url: song.artworkURL,
            size: MCArtworkSize.player,
            cornerRadius: MCRadius.largeArtwork
        )

        Spacer(minLength: 76)

        PlayerMetadataView(song: song)

        PlayerProgressView(
            elapsedTime: viewModel.elapsedTime,
            duration: viewModel.duration,
            progress: viewModel.progress
        )
        .accessibilityIdentifier("player-progress")
        .padding(.top, MCSpacing.large)

        if let message = viewModel.message {
            Text(message)
                .font(MCTypography.songSubtitle)
                .foregroundStyle(MCColor.secondaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, MCSpacing.medium)
                .accessibilityLabel(message)
        }

        MCPlayerControls(
            isPlaying: viewModel.isPlaying,
            isPreviousEnabled: false,
            isNextEnabled: false,
            onPlayPause: {
                Task {
                    await viewModel.playPauseTapped()
                }
            }
        )
        .disabled(viewModel.isPlaybackDisabled)
        .opacity(viewModel.isPlaybackDisabled ? 0.44 : 1)
        .padding(.top, MCSpacing.xLarge)

        Spacer(minLength: 0)
    }
}

private struct PlayerNavigationBar: View {
    let title: String
    let showsBackButton: Bool
    let onBack: () -> Void
    let onMoreOptions: () -> Void

    var body: some View {
        ZStack {
            HStack {
                if showsBackButton {
                    MCCircularIconButton(systemName: "chevron.left", accessibilityLabel: "Back", action: onBack)
                } else {
                    Color.clear
                        .frame(width: MCControlSize.navigationButton, height: MCControlSize.navigationButton)
                }

                Spacer(minLength: 0)

                MCCircularIconButton(systemName: "ellipsis", accessibilityLabel: "More options", action: onMoreOptions)
            }

            Text(title)
                .font(MCTypography.navigationTitle)
                .foregroundStyle(MCColor.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .padding(.horizontal, MCControlSize.navigationButton + MCSpacing.xLarge)
        }
        .frame(height: MCControlSize.navigationButton)
    }
}

private struct PlayerMetadataView: View {
    let song: Song

    var body: some View {
        HStack(alignment: .bottom, spacing: MCSpacing.medium) {
            VStack(alignment: .leading, spacing: MCSpacing.small) {
                Text(song.title)
                    .font(MCTypography.playerTitle)
                    .foregroundStyle(MCColor.primaryText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)

                Text(song.artist.name)
                    .font(MCTypography.playerSubtitle)
                    .foregroundStyle(MCColor.secondaryText)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            Image(systemName: "shuffle")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(MCColor.primaryText)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct PlayerProgressView: View {
    let elapsedTime: TimeInterval
    let duration: TimeInterval
    let progress: Double

    var body: some View {
        VStack(spacing: MCSpacing.xSmall) {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(MCColor.secondaryText)
                        .frame(height: 5)

                    Capsule()
                        .fill(MCColor.primaryText)
                        .frame(width: proxy.size.width * progress, height: 5)
                        .animation(MCAnimation.quick, value: progress)

                    Circle()
                        .fill(MCColor.primaryText)
                        .frame(width: 18, height: 18)
                        .offset(x: max(0, proxy.size.width * progress - 9))
                        .animation(MCAnimation.quick, value: progress)
                }
                .frame(maxHeight: .infinity)
            }
            .frame(height: 18)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Playback progress")
            .accessibilityValue("\(format(elapsedTime)) of \(format(duration))")

            HStack {
                Text(format(elapsedTime))
                Spacer(minLength: 0)
                Text("-\(format(max(0, duration - elapsedTime)))")
            }
            .font(MCTypography.timeLabel)
            .foregroundStyle(MCColor.secondaryText)
        }
    }

    private func format(_ time: TimeInterval) -> String {
        guard time.isFinite, time > 0 else { return "0:00" }

        let totalSeconds = Int(time.rounded(.down))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
}

#Preview {
    PlayerScreen(
        song: Song(
            id: "get-lucky",
            title: "Get Lucky",
            artist: Artist(id: "daft-punk", name: "Daft Punk feat. Pharrell Williams"),
            albumTitle: "Album title",
            artworkURL: URL(string: "https://example.com/artwork.jpg"),
            duration: 240
        ),
        viewModel: PlayerViewModel(
            song: Song(
                id: "get-lucky",
                title: "Get Lucky",
                artist: Artist(id: "daft-punk", name: "Daft Punk feat. Pharrell Williams"),
                albumTitle: "Album title",
                duration: 240
            ),
            repository: PreviewPlayerRepository()
        ),
        showsBackButton: true,
        onBack: {},
        onMoreOptions: {}
    )
}

@MainActor
private final class PreviewPlayerRepository: PlayerRepository {
    func requestAuthorization() async -> MusicAuthorizationState { .authorized }

    func currentState() async throws -> PlaybackState {
        PlaybackState(
            authorization: .authorized,
            availability: .playable,
            status: .paused,
            elapsedTime: 86,
            duration: 240
        )
    }

    func play(song: Song) async throws {}
    func pause() async {}
    func resume() async throws {}
    func saveRecentlyPlayed(_ song: Song) async throws {}

    func progressUpdates(every interval: Duration) -> AsyncStream<PlaybackState> {
        AsyncStream { continuation in
            continuation.finish()
        }
    }
}
