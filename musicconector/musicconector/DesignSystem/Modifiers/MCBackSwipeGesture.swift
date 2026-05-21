//
//  MCBackSwipeGesture.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 21/05/26.
//

import SwiftUI

private struct MCBackSwipeGesture: ViewModifier {
    let isEnabled: Bool
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 24, coordinateSpace: .local)
                    .onEnded { value in
                        guard isEnabled, shouldNavigateBack(with: value) else { return }
                        action()
                    }
            )
    }

    private func shouldNavigateBack(with value: DragGesture.Value) -> Bool {
        value.translation.width > 80
            && abs(value.translation.height) < 72
            && value.predictedEndTranslation.width > value.translation.width
    }
}

extension View {
    func mcBackSwipeGesture(isEnabled: Bool = true, action: @escaping () -> Void) -> some View {
        modifier(MCBackSwipeGesture(isEnabled: isEnabled, action: action))
    }
}
