//
//  iOSApp5App.swift
//  iOSApp5
//
//  Created by Etefworkie Melaku on 2026-07-08.
//
// App entry point. Creates the shared SoundPlayer and sets up the two-tab TabView.

import SwiftUI

@main
struct iOSApp5App: App {
    // One SoundPlayer lives for the entire app lifetime.
    // @State keeps it alive across re-renders; .environment() shares it with every view in the tree.
    @State private var soundPlayer = SoundPlayer()

    var body: some Scene {
        WindowGroup {
            // TabView gives the app two tabs — the animal grid and the quiz.
            // Both tabs share the same SoundPlayer so sounds never overlap between tabs.
            TabView {
                AnimalGridView()
                    .tabItem {
                        Label("Animals", systemImage: "pawprint.fill")
                    }

                QuizView()
                    .tabItem {
                        Label("Quiz", systemImage: "questionmark.circle.fill")
                    }
            }
            .environment(soundPlayer)
        }
    }
}
