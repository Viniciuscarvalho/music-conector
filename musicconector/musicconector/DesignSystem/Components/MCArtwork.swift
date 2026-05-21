//
//  MCArtwork.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import SwiftUI

struct MCArtwork: View {
    let url: URL?
    let size: CGFloat
    let cornerRadius: CGFloat

    init(url: URL?, size: CGFloat = MCArtworkSize.row, cornerRadius: CGFloat = MCRadius.artwork) {
        self.url = url
        self.size = size
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure, .empty:
                placeholder
            @unknown default:
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .accessibilityLabel("Artwork")
        .accessibilityIdentifier("artwork")
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(MCColor.surface)
            .overlay {
                Image(systemName: "music.note")
                    .font(.system(size: max(14, size * 0.34), weight: .semibold))
                    .foregroundStyle(MCColor.accent)
            }
    }
}

#Preview {
    MCArtwork(url: nil, size: MCArtworkSize.player, cornerRadius: MCRadius.largeArtwork)
        .padding()
        .background(MCColor.background)
}
