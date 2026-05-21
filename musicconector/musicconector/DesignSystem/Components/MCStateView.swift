//
//  MCStateView.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import SwiftUI

struct MCStateView: View {
    let symbolName: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        symbolName: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.symbolName = symbolName
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: MCSpacing.large) {
            Image(systemName: symbolName)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(MCColor.accent)
                .frame(width: 96, height: 96)
                .background(MCColor.surface, in: RoundedRectangle(cornerRadius: MCRadius.largeArtwork, style: .continuous))
                .accessibilityHidden(true)

            VStack(spacing: MCSpacing.xSmall) {
                Text(title)
                    .font(MCTypography.navigationTitle)
                    .foregroundStyle(MCColor.primaryText)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(MCTypography.body)
                    .foregroundStyle(MCColor.secondaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(MCTypography.body)
                    .foregroundStyle(MCColor.primaryText)
                    .padding(.horizontal, MCSpacing.large)
                    .frame(minHeight: MCControlSize.searchHeight)
                    .background(MCColor.surface, in: RoundedRectangle(cornerRadius: MCRadius.searchField, style: .continuous))
            }
        }
        .padding(.horizontal, MCSpacing.xxLarge)
        .accessibilityElement(children: .contain)
    }
}

struct MCLoadingStateView: View {
    let title: String

    init(title: String = "Loading") {
        self.title = title
    }

    var body: some View {
        VStack(spacing: MCSpacing.medium) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(MCColor.primaryText)

            Text(title)
                .font(MCTypography.body)
                .foregroundStyle(MCColor.secondaryText)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
    }
}

#Preview {
    MCStateView(
        symbolName: "wifi.exclamationmark",
        title: "Connection unavailable",
        message: "Check your internet connection and try again.",
        actionTitle: "Retry"
    ) {}
    .padding()
    .background(MCColor.background)
}
