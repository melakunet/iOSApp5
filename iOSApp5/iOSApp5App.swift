//
//  iOSApp5App.swift
//  iOSApp5
//
//  Created by Etefworkie Melaku on 2026-07-08.
//

import SwiftUI

@main
struct iOSApp5App: App {
    // One SoundPlayer lives for the entire app lifetime.
    // @State here tells SwiftUI to keep this instance alive across re-renders of the App struct.
    // We inject it with .environment() so any view in the tree can read it without prop drilling.
    @State private var soundPlayer = SoundPlayer()

    var body: some Scene {
        WindowGroup {
            AnimalGridView()
                .environment(soundPlayer)
        }
    }
}
