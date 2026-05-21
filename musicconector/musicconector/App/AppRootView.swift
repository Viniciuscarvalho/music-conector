//
//  AppRootView.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 21/05/26.
//

import SwiftUI

struct AppRootView: View {
    @State private var isShowingSplash = true

    var body: some View {
        ZStack {
            if isShowingSplash {
                SplashScreen()
                    .transition(.opacity)
            } else {
                ContentView()
                    .transition(.opacity)
            }
        }
        .background(MCColor.background)
        .task {
            await hideSplashAfterMinimumDuration()
        }
    }

    private func hideSplashAfterMinimumDuration() async {
        do {
            try await Task.sleep(for: .milliseconds(900))
        } catch {
            return
        }

        guard !Task.isCancelled else { return }
        withAnimation(.easeOut(duration: 0.22)) {
            isShowingSplash = false
        }
    }
}
