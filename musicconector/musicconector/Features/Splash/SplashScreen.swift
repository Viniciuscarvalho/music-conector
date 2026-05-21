//
//  SplashScreen.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 21/05/26.
//

import SwiftUI

struct SplashScreen: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Image(SplashAsset(horizontalSizeClass: horizontalSizeClass).rawValue)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .background(MCColor.background)
            .accessibilityHidden(true)
    }
}

#Preview("iPhone") {
    SplashScreen()
        .environment(\.horizontalSizeClass, .compact)
}

#Preview("iPad") {
    SplashScreen()
        .environment(\.horizontalSizeClass, .regular)
}
