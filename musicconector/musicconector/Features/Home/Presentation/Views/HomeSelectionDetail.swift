//
//  HomeSelectionDetail.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import SwiftUI

struct HomeSelectionDetail: View {
    let song: Song?

    var body: some View {
        ZStack {
            MCColor.background
                .ignoresSafeArea()

            if let song {
                VStack(spacing: MCSpacing.large) {
                    MCArtwork(url: song.artworkURL, size: 180, cornerRadius: MCRadius.largeArtwork)

                    VStack(spacing: MCSpacing.xSmall) {
                        Text(song.title)
                            .font(MCTypography.screenTitle)
                            .foregroundStyle(MCColor.primaryText)
                            .multilineTextAlignment(.center)

                        Text(song.artist.name)
                            .font(MCTypography.body)
                            .foregroundStyle(MCColor.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(MCSpacing.xxLarge)
                .accessibilityElement(children: .combine)
            } else {
                Text("Select a song")
                    .font(MCTypography.navigationTitle)
                    .foregroundStyle(MCColor.secondaryText)
            }
        }
    }
}
