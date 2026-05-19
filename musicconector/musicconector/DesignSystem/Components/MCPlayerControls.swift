//
//  MCPlayerControls.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import SwiftUI

struct MCPlayerControls: View {
    let isPlaying: Bool
    let isPreviousEnabled: Bool
    let isNextEnabled: Bool
    let onPrevious: () -> Void
    let onPlayPause: () -> Void
    let onNext: () -> Void

    init(
        isPlaying: Bool,
        isPreviousEnabled: Bool = true,
        isNextEnabled: Bool = true,
        onPrevious: @escaping () -> Void = {},
        onPlayPause: @escaping () -> Void = {},
        onNext: @escaping () -> Void = {}
    ) {
        self.isPlaying = isPlaying
        self.isPreviousEnabled = isPreviousEnabled
        self.isNextEnabled = isNextEnabled
        self.onPrevious = onPrevious
        self.onPlayPause = onPlayPause
        self.onNext = onNext
    }

    var body: some View {
        HStack(spacing: MCSpacing.xLarge) {
            Button(action: onPrevious) {
                Image(systemName: "backward.fill")
                    .font(.system(size: 22, weight: .bold))
                    .frame(width: MCControlSize.playerSecondaryButton, height: MCControlSize.playerSecondaryButton)
            }
            .disabled(!isPreviousEnabled)
            .accessibilityLabel("Previous song")

            Button(action: onPlayPause) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.leading, isPlaying ? 0 : 4)
                    .frame(width: MCControlSize.playerPrimaryButton, height: MCControlSize.playerPrimaryButton)
                    .background(MCColor.controlFill, in: Circle())
                    .overlay {
                        Circle().stroke(MCColor.separator, lineWidth: 1)
                    }
            }
            .accessibilityLabel(isPlaying ? "Pause" : "Play")

            Button(action: onNext) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 22, weight: .bold))
                    .frame(width: MCControlSize.playerSecondaryButton, height: MCControlSize.playerSecondaryButton)
            }
            .disabled(!isNextEnabled)
            .accessibilityLabel("Next song")
        }
        .buttonStyle(.plain)
        .foregroundStyle(MCColor.primaryText)
    }
}

#Preview {
    MCPlayerControls(isPlaying: false)
        .padding()
        .background(MCColor.background)
}
