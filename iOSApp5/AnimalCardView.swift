//
//  AnimalCardView.swift
//  iOSApp5
//
//  Created by Etefworkie Melaku on 2026-07-09.
//
// One card in the home-screen grid. Tapping the image area plays the animal's sound;
// the "See more" button at the bottom pushes AnimalDetailView onto the navigation stack.

import SwiftUI

struct AnimalCardView: View {
    let animal: Animal

    // We pull the shared SoundPlayer from the environment instead of passing it through
    // every parent view — this keeps the card's own interface clean and simple.
    @Environment(SoundPlayer.self) private var soundPlayer

    // True while this animal's sound is actively playing.
    // Driving the animation from this computed property means it updates automatically
    // whenever soundPlayer.currentlyPlaying changes — no manual bookkeeping needed.
    private var isPlaying: Bool {
        soundPlayer.currentlyPlaying == animal.assetName
    }

    var body: some View {
        VStack(spacing: 0) {

            // ── Sound tap area ──────────────────────────────────────────────
            // The image and name together form one big tap target that plays the sound.
            VStack(spacing: 12) {
                ZStack {
                    // Light placeholder shape so there is something visible on screen
                    // before the real image assets are added to the project.
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white.opacity(0.25))

                    Image(animal.assetName)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .aspectRatio(1, contentMode: .fit)

                Text(animal.name)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            // contentShape makes the whole rectangle tappable, not just the image pixels.
            .contentShape(Rectangle())
            .onTapGesture {
                soundPlayer.play(animal.assetName)
            }
            // Merge the image and name into one accessibility element so VoiceOver
            // reads them as a single button rather than two separate items.
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(animal.name). Tap to hear the \(animal.name.lowercased()) sound.")
            .accessibilityAddTraits(.isButton)

            // ── Navigation row ──────────────────────────────────────────────
            // A clearly labelled button so a child (or parent) knows more detail exists.
            NavigationLink(destination: AnimalDetailView(animal: animal)) {
                HStack(spacing: 6) {
                    Text("See more")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(.black.opacity(0.15))
            }
            // Plain style removes the default blue tint that NavigationLink adds.
            .buttonStyle(.plain)
            // Override the default label (which includes the chevron icon name) with
            // something a screen reader can speak clearly.
            .accessibilityLabel("See more about \(animal.name)")
        }
        .background(animal.cardColor)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)
        // Scale up slightly when playing — the spring's natural overshoot creates the bounce.
        // When the sound ends, currentlyPlaying becomes nil and the card springs back to 1.0.
        .scaleEffect(isPlaying ? 1.06 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.45), value: isPlaying)
    }
}

#Preview {
    // Wrap in NavigationStack so the NavigationLink inside the card works in the preview.
    NavigationStack {
        AnimalCardView(animal: Animal.all[0])
            .padding()
            .environment(SoundPlayer())
    }
}
