//
//  SoundPlayer.swift
//  iOSApp5
//
//  Created by Etefworkie Melaku on 2026-07-08.
//

import AVFoundation
import Observation

// SoundPlayer is a class (not a struct) because AVAudioPlayer is a reference type and we need
// to keep the same player alive while audio is playing — if it gets deallocated, the sound stops.
// @Observable lets SwiftUI views react when currentlyPlaying changes without any extra boilerplate.
@Observable
class SoundPlayer {

    // We keep the player as a property so it stays in memory for the full duration of playback.
    // A local variable inside play() would be released as soon as the function returns.
    private var player: AVAudioPlayer?

    // The assetName of whichever animal sound is currently playing, or nil when nothing is playing.
    // Views can watch this to highlight the active card.
    var currentlyPlaying: String?

    init() {
        // Set the audio session once at startup so the app plays sound even when the device
        // is in silent / vibrate mode — important for a kids app where parents often mute the ring.
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("SoundPlayer: could not set up AVAudioSession – \(error)")
        }
    }

    // Play the mp3 whose filename matches assetName (e.g. "dog" loads "dog.mp3").
    // If the same sound is tapped again while already playing we restart it from the beginning.
    func play(_ assetName: String) {
        guard let url = Bundle.main.url(forResource: assetName, withExtension: "mp3") else {
            // The file is missing from the bundle — warn the developer but don't crash the app.
            print("SoundPlayer: could not find \(assetName).mp3 in the app bundle")
            return
        }

        // Stop whatever was playing before so sounds don't overlap.
        player?.stop()

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
            currentlyPlaying = assetName
        } catch {
            print("SoundPlayer: failed to create player for \(assetName).mp3 – \(error)")
        }
    }
}
