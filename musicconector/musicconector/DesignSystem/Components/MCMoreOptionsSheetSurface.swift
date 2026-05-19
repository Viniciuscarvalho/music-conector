//
//  MCMoreOptionsSheetSurface.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import SwiftUI

struct MCMoreOptionsSheetSurface<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    init(title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: MCSpacing.xSmall) {
                Text(title)
                    .font(MCTypography.songTitle)
                    .foregroundStyle(MCColor.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(MCTypography.songSubtitle)
                    .foregroundStyle(MCColor.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, MCSpacing.xLarge)
            .padding(.vertical, MCSpacing.large)

            Divider()
                .overlay(MCColor.separator)

            content
                .padding(.horizontal, MCSpacing.xLarge)
                .padding(.vertical, MCSpacing.large)
        }
        .background(MCColor.elevatedSurface, in: RoundedRectangle(cornerRadius: MCRadius.sheet, style: .continuous))
        .accessibilityElement(children: .contain)
    }
}

struct MCMoreOptionsActionRow: View {
    let systemName: String
    let title: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: MCSpacing.medium) {
                Image(systemName: systemName)
                    .frame(width: 24, height: 24)
                    .accessibilityHidden(true)

                Text(title)
                    .font(MCTypography.body)

                Spacer()
            }
            .foregroundStyle(MCColor.primaryText)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MCMoreOptionsSheetSurface(title: "Song name", subtitle: "Artist name") {
        MCMoreOptionsActionRow(systemName: "music.note.list", title: "View album") {}
    }
    .padding()
    .background(MCColor.background)
}
