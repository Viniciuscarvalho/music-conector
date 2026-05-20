//
//  MCSearchField.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import SwiftUI

struct MCSearchField: View {
    @Binding var text: String
    let prompt: LocalizedStringKey
    let onSubmit: () -> Void

    init(
        text: Binding<String>,
        prompt: LocalizedStringKey = "Search",
        onSubmit: @escaping () -> Void = {}
    ) {
        self._text = text
        self.prompt = prompt
        self.onSubmit = onSubmit
    }

    var body: some View {
        HStack(spacing: MCSpacing.small) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(MCColor.tertiaryText)
                .accessibilityHidden(true)

            TextField(prompt, text: $text)
                .font(MCTypography.body)
                .foregroundStyle(MCColor.primaryText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onSubmit(onSubmit)
        }
        .padding(.horizontal, MCSpacing.medium)
        .frame(minHeight: MCControlSize.searchHeight)
        .background(MCColor.surface, in: RoundedRectangle(cornerRadius: MCRadius.searchField, style: .continuous))
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    @Previewable @State var searchText = ""

    MCSearchField(text: $searchText)
        .padding()
        .background(MCColor.background)
}
