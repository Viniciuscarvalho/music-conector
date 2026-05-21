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
    let isFocused: FocusState<Bool>.Binding?
    let onSubmit: () -> Void
    @FocusState private var internalFocus: Bool

    init(
        text: Binding<String>,
        prompt: LocalizedStringKey = "Search",
        isFocused: FocusState<Bool>.Binding? = nil,
        onSubmit: @escaping () -> Void = {}
    ) {
        self._text = text
        self.prompt = prompt
        self.isFocused = isFocused
        self.onSubmit = onSubmit
    }

    var body: some View {
        HStack(spacing: MCSpacing.small) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(MCColor.tertiaryText)
                .accessibilityHidden(true)

            searchTextField
        }
        .padding(.horizontal, MCSpacing.medium)
        .frame(minHeight: MCControlSize.searchHeight)
        .background(MCColor.surface, in: RoundedRectangle(cornerRadius: MCRadius.searchField, style: .continuous))
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var searchTextField: some View {
        if let isFocused {
            baseSearchTextField
                .focused(isFocused)
        } else {
            baseSearchTextField
                .focused($internalFocus)
        }
    }

    private var baseSearchTextField: some View {
        TextField(prompt, text: $text)
            .font(MCTypography.body)
            .foregroundStyle(MCColor.primaryText)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.search)
            .onSubmit(onSubmit)
    }
}

#Preview {
    @Previewable @State var searchText = ""

    MCSearchField(text: $searchText)
        .padding()
        .background(MCColor.background)
}
