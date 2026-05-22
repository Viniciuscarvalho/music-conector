//
//  MCMoreOptionsSheetSurface.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import SwiftUI

private enum MCMoreOptionsSheetLayout {
    static let horizontalPadding: CGFloat = 16
    static let headerBottomPadding: CGFloat = 12
    static let contentBottomPadding: CGFloat = 8
    static let grabberTopPadding: CGFloat = 4
    static let grabberBottomPadding: CGFloat = 10
    static let actionSpacing: CGFloat = 10
    static let iconFrame: CGFloat = 24
    static let iconSize: CGFloat = 16
    static let actionMinHeight: CGFloat = 44
}

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
            Capsule()
                .fill(MCColor.secondaryText.opacity(0.52))
                .frame(width: 38, height: 4)
                .padding(.top, MCMoreOptionsSheetLayout.grabberTopPadding)
                .padding(.bottom, MCMoreOptionsSheetLayout.grabberBottomPadding)
                .accessibilityHidden(true)

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
            .padding(.horizontal, MCMoreOptionsSheetLayout.horizontalPadding)
            .padding(.bottom, MCMoreOptionsSheetLayout.headerBottomPadding)

            content
                .padding(.horizontal, MCMoreOptionsSheetLayout.horizontalPadding)
                .padding(.bottom, MCMoreOptionsSheetLayout.contentBottomPadding)
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
            HStack(spacing: MCMoreOptionsSheetLayout.actionSpacing) {
                Image(systemName: systemName)
                    .font(.system(size: MCMoreOptionsSheetLayout.iconSize, weight: .regular))
                    .frame(
                        width: MCMoreOptionsSheetLayout.iconFrame,
                        height: MCMoreOptionsSheetLayout.iconFrame
                    )
                    .accessibilityHidden(true)

                Text(title)
                    .font(MCTypography.body)

                Spacer()
            }
            .foregroundStyle(MCColor.primaryText)
            .frame(minHeight: MCMoreOptionsSheetLayout.actionMinHeight)
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
