//
//  DrekiApp.swift
//  Dreki
//
//  Created by Kristofer Younger on 9/17/25.
//

import SwiftUI
import SwiftData

@main
struct DrekiApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Project.self, Expense.self,
        ])

        let modelConfiguration = ModelConfiguration(schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }

    }()

    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashScreenView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                showSplash = false
                            }
                        }
                } else {
                    ContentView()
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
