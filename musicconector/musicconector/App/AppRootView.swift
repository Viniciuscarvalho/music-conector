//
//  AppRootView.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 21/05/26.
//

import SwiftUI

struct AppRootView: View {
    private let authorizationProvider: MusicAuthorizationProviding
    private let skipsSplashAndAuthorization: Bool
    @State private var isShowingSplash: Bool

    init(
        authorizationProvider: MusicAuthorizationProviding = MusicKitAuthorizationProvider(),
        skipsSplashAndAuthorization: Bool = ProcessInfo.processInfo.arguments.contains("-ui-testing")
    ) {
        self.authorizationProvider = authorizationProvider
        self.skipsSplashAndAuthorization = skipsSplashAndAuthorization
        self._isShowingSplash = State(initialValue: !skipsSplashAndAuthorization)
    }

    var body: some View {
        ZStack {
            if isShowingSplash {
                SplashScreen()
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
                    .zIndex(1)
            } else {
                ContentView()
                    .transition(.opacity.combined(with: .scale(scale: 0.985)))
                    .zIndex(0)
            }
        }
        .background(MCColor.background)
        .task {
            await dismissSplashAndRequestMusicAccess()
        }
    }

    private func dismissSplashAndRequestMusicAccess() async {
        guard !skipsSplashAndAuthorization else { return }

        do {
            try await Task.sleep(for: .milliseconds(950))
        } catch {
            return
        }

        guard !Task.isCancelled else { return }

        withAnimation(MCAnimation.splashExit) {
            isShowingSplash = false
        }

        do {
            try await Task.sleep(for: .milliseconds(200))
        } catch {
            return
        }

        guard !Task.isCancelled else { return }
        _ = await authorizationProvider.requestAuthorization()
    }
}
