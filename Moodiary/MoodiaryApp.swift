//
//  MoodiaryApp.swift
//  Moodiary
//
//  Created by F1reC on 2024/9/17.
//

import SwiftUI
import SwiftData

@main
struct MoodiaryApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            UserModel.self  // 添加 UserModel 到 schema
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            // 设置共享的 ModelContext
            ModelContextManager.shared.modelContext = ModelContext(container)
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
