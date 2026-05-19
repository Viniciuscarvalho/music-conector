//
//  MCSongRow.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import SwiftUI

struct MCSongRow: View {
    let content: MCSongRowContent
    let showsMoreButton: Bool
    let onTap: () -> Void
    let onMore: () -> Void

    @ScaledMetric(relativeTo: .body) private var artworkSize = MCArtworkSize.row

    init(
        content: MCSongRowContent,
        showsMoreButton: Bool = true,
        onTap: @escaping () -> Void = {},
        onMore: @escaping () -> Void = {}
    ) {
        self.content = content
        self.showsMoreButton = showsMoreButton
        self.onTap = onTap
        self.onMore = onMore
    }

    var body: some View {
        HStack(spacing: MCSpacing.medium) {
            Button(action: onTap) {
                HStack(spacing: MCSpacing.medium) {
                    MCArtwork(url: content.artworkURL, size: artworkSize)

                    VStack(alignment: .leading, spacing: MCSpacing.xxSmall) {
                        Text(content.title)
                            .font(MCTypography.songTitle)
                            .foregroundStyle(MCColor.primaryText)
                            .lineLimit(2)

                        Text(content.subtitle)
                            .font(MCTypography.songSubtitle)
                            .foregroundStyle(MCColor.secondaryText)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .contentShape(Rectangle())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(content.title), \(content.subtitle)")

            if showsMoreButton {
                Button(action: onMore) {
                    Image(systemName: "ellipsis")
                        .font(.system(.caption, weight: .semibold))
                        .foregroundStyle(MCColor.tertiaryText)
                        .frame(
                            width: MCControlSize.rowMenuButton,
                            height: MCControlSize.rowMenuButton
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("More options for \(content.title)")
            }
        }
    }
}

#Preview {
    VStack(spacing: MCSpacing.large) {
        MCSongRow(
            content: MCSongRowContent(
                id: "1",
                title: "Get Lucky",
                subtitle: "Daft Punk feat. Pharrell Williams"
            )
        )
    }
    .padding()
    .background(MCColor.background)
}
