//
//  MCAnimation.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 21/05/26.
//

import SwiftUI

enum MCAnimation {
    static let quick = Animation.spring(response: 0.28, dampingFraction: 0.86, blendDuration: 0.06)
    static let standard = Animation.spring(response: 0.42, dampingFraction: 0.88, blendDuration: 0.1)
    static let emphasized = Animation.spring(response: 0.56, dampingFraction: 0.82, blendDuration: 0.12)
    static let splashExit = Animation.easeInOut(duration: 0.42)
}

extension AnyTransition {
    static var mcContent: AnyTransition {
        .opacity.combined(with: .scale(scale: 0.98))
    }

    static var mcRow: AnyTransition {
        .opacity.combined(with: .move(edge: .bottom))
    }
}
