//
//  iOSApp5Tests.swift
//  iOSApp5Tests
//
//  Created by Etefworkie Melaku on 2026-07-08.
//
// Unit tests for the Animal model and SoundPlayer class.
// Checks that all 8 animals have the correct data and that their media files are in the bundle.

import Testing
import UIKit
@testable import iOSApp5

// Tests for the Animal data model.
// We test the model first because everything else in the app depends on it being correct.
struct AnimalModelTests {

    // The app is built around exactly 8 animals — if someone adds or removes one by accident
    // this test will catch it right away.
    @Test func animalAllHasEightEntries() {
        #expect(Animal.all.count == 8)
    }

    // If two animals share an assetName they would play each other's sounds and videos,
    // so every assetName must be different from all the others.
    @Test func assetNamesAreUnique() {
        let names = Animal.all.map { $0.assetName }
        #expect(Set(names).count == names.count)
    }

    // The mp3, mp4, and image files in the bundle are all stored with lowercase names.
    // If an assetName has any uppercase letters Bundle.main.url will return nil.
    @Test func assetNamesAreLowercase() {
        for animal in Animal.all {
            #expect(
                animal.assetName == animal.assetName.lowercased(),
                "'\(animal.assetName)' contains uppercase letters — bundle lookup will fail"
            )
        }
    }

    // If an mp3 is missing from the bundle the sound button is silently skipped,
    // which would confuse a child expecting to hear the animal.
    @Test func allMp3sExistInBundle() {
        for animal in Animal.all {
            let url = Bundle.main.url(forResource: animal.assetName, withExtension: "mp3")
            #expect(url != nil, "\(animal.assetName).mp3 not found in the app bundle")
        }
    }

    // If an mp4 is missing the detail screen shows the placeholder instead of the real video.
    // This test confirms every animal has its video in place.
    @Test func allMp4sExistInBundle() {
        for animal in Animal.all {
            let url = Bundle.main.url(forResource: animal.assetName, withExtension: "mp4")
            #expect(url != nil, "\(animal.assetName).mp4 not found in the app bundle")
        }
    }

    // If an image is missing from the asset catalog the card shows a blank placeholder area.
    // UIImage(named:) returns nil when the image set doesn't exist.
    @Test func allImagesExistInAssets() {
        for animal in Animal.all {
            let image = UIImage(named: animal.assetName)
            #expect(image != nil, "Image '\(animal.assetName)' not found in Assets.xcassets")
        }
    }

    // If a feedback clip is missing the quiz plays silence instead of a voice phrase.
    // win1–win9 are played on a correct answer; try1–try6 are played on a wrong answer.
    @Test func allFeedbackClipsExistInBundle() {
        let winFiles = (1...9).map { "win\($0)" }
        let tryFiles = (1...6).map { "try\($0)" }
        for name in winFiles + tryFiles {
            let url = Bundle.main.url(forResource: name, withExtension: "mp3")
            #expect(url != nil, "\(name).mp3 not found in the app bundle")
        }
    }
}

// Tests for SoundPlayer.
// We test the logic here — we don't need actual audio to play to verify the state is correct.
struct SoundPlayerTests {

    // When a valid mp3 exists in the bundle, play() must update currentlyPlaying
    // so the grid card knows to show the bounce animation.
    @Test func playValidNameSetsCurrentlyPlaying() {
        let player = SoundPlayer()
        player.play("dog")
        #expect(player.currentlyPlaying == "dog")
    }

    // If the mp3 file doesn't exist, play() must give up quietly without crashing.
    // currentlyPlaying should stay nil because nothing actually started playing.
    @Test func playBogusNameDoesNotCrashAndLeavesCurrentlyPlayingNil() {
        let player = SoundPlayer()
        player.play("not_a_real_animal_xyz")
        #expect(player.currentlyPlaying == nil)
    }

    // After a valid play call, calling play() with a bogus name should not overwrite
    // currentlyPlaying with the bogus name — it should stay as the last valid animal.
    @Test func playBogusNameAfterValidDoesNotOverwriteCurrentlyPlaying() {
        let player = SoundPlayer()
        player.play("cat")
        let beforeBogus = player.currentlyPlaying
        player.play("not_real_xyz")
        // currentlyPlaying should still be "cat" because the bogus call exited early.
        #expect(player.currentlyPlaying == beforeBogus)
    }
}
