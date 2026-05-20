//
//  musicconectorApp.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import SwiftData
import SwiftUI

@main
struct musicconectorApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CachedAlbum.self,
            CachedSong.self,
            RecentPlay.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    _ = await MusicKitAuthorizationProvider().currentStatus()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
