//
//  Animal.swift
//  iOSApp5
//
//  Created by Etefworkie Melaku on 2026-07-08.
//
// Data model. Defines the Animal struct and the static list of all 8 animals.
// Every view in the app reads from Animal.all — it is the single source of truth for all animal data.

import SwiftUI

// Each Animal holds everything the app needs to show a card, play a sound, and play a video.
// Using Identifiable lets us loop over animals in ForEach without needing a manual id parameter.
// Using Hashable lets us use Animal values in Sets or as NavigationPath items later.
struct Animal: Identifiable, Hashable {
    let id = UUID()
    let name: String         // Display name shown on the card, e.g. "Dog"
    let assetName: String    // Lowercase key used to load image, mp3, and mp4 files, e.g. "dog"
    let fact: String         // A short, fun fact a preschooler can understand
    let cardColor: Color     // Background color that makes each card feel unique

    // All 8 animals the app supports.
    // Keeping the list here means every view in the app can access it without passing it around.
    static let all: [Animal] = [
        Animal(name: "Dog",      assetName: "dog",      fact: "Dogs wag their tails when they are happy!",        cardColor: .orange),
        Animal(name: "Cat",      assetName: "cat",      fact: "Cats purr to show they feel safe and cozy.",       cardColor: .purple),
        Animal(name: "Cow",      assetName: "cow",      fact: "Cows have best friends and get sad when apart.",   cardColor: .green),
        Animal(name: "Lion",     assetName: "lion",     fact: "A lion's roar can be heard 8 kilometres away!",   cardColor: .yellow),
        Animal(name: "Elephant", assetName: "elephant", fact: "Elephants never forget a friend they have met.",  cardColor: .teal),
        Animal(name: "Duck",     assetName: "duck",     fact: "Ducks have waterproof feathers to stay dry.",     cardColor: .cyan),
        Animal(name: "Horse",    assetName: "horse",    fact: "Horses can sleep standing up!",                   cardColor: .brown),
        Animal(name: "Sheep",    assetName: "sheep",    fact: "Sheep can recognise up to 50 other sheep faces.", cardColor: .mint),
    ]
}
