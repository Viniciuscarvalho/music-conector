//
//  MCCircularIconButton.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import SwiftUI

struct MCCircularIconButton: View {
    let systemName: String
    let accessibilityLabel: LocalizedStringKey
    let size: CGFloat
    let foregroundStyle: Color
    let backgroundStyle: Color
    let action: () -> Void

    init(
        systemName: String,
        accessibilityLabel: LocalizedStringKey,
        size: CGFloat = MCControlSize.navigationButton,
        foregroundStyle: Color = MCColor.primaryText,
        backgroundStyle: Color = MCColor.surface,
        action: @escaping () -> Void
    ) {
        self.systemName = systemName
        self.accessibilityLabel = accessibilityLabel
        self.size = size
        self.foregroundStyle = foregroundStyle
        self.backgroundStyle = backgroundStyle
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(foregroundStyle)
                .frame(width: size, height: size)
                .background(backgroundStyle, in: Circle())
                .overlay {
                    Circle()
                        .stroke(MCColor.separator, lineWidth: 1)
                }
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    private var iconSize: CGFloat {
        min(22, max(13, size * 0.42))
    }
}

#Preview {
    HStack {
        MCCircularIconButton(systemName: "chevron.left", accessibilityLabel: "Back") {}
        MCCircularIconButton(systemName: "ellipsis", accessibilityLabel: "More options") {}
    }
    .padding()
    .background(MCColor.background)
}
