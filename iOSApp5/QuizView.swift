//
//  QuizView.swift
//  iOSApp5
//
//  Created by Etefworkie Melaku on 2026-07-09.
//
// The Quiz tab. Plays a random animal sound and shows 3 image choices for the child to pick.
// Correct tap triggers a full-screen celebration and audio praise; wrong tap shakes the card and plays encouragement.

import SwiftUI

// ShakeEffect translates a view side to side in a wave pattern.
// SwiftUI interpolates animatableData on every animation frame and we use its value
// as the input to a sine function to produce the back-and-forth motion.
struct ShakeEffect: GeometryEffect {
    // SwiftUI writes interpolated values into this property during an animation,
    // so the shake stays in sync with whatever animation curve is active.
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        // Multiplying by 3 gives 3 full oscillations over one animation unit,
        // which feels like a natural "that's wrong" shake.
        let translation = sin(animatableData * .pi * 3) * 10
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

// A single answer card for the quiz — just the visual, no tap logic.
// The parent QuizView adds the tap handler and animation modifiers so all
// game logic stays in one place.
struct QuizChoiceCard: View {
    let animal: Animal

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Coloured background matches the animal's card colour from the grid,
                // so the quiz feels visually consistent with the rest of the app.
                RoundedRectangle(cornerRadius: 12)
                    .fill(animal.cardColor.opacity(0.2))

                Image(animal.assetName)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(6)
            }
            .aspectRatio(1, contentMode: .fit)

            Text(animal.name)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
        }
        .padding(10)
        // maxWidth: .infinity inside an HStack makes all three cards share the width equally.
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct QuizView: View {
    @Environment(SoundPlayer.self) private var soundPlayer

    // The animal whose sound is played in the current round.
    @State private var correctAnimal: Animal = Animal.all[0]
    // The three cards shown to the child: the correct one plus two random others, shuffled.
    @State private var choices: [Animal] = []

    // True while the celebration overlay is on screen after a correct answer.
    @State private var showCelebration = false

    // Each card has its own shake counter so wrong taps on different cards animate independently.
    // Incrementing a value triggers a new shake; SwiftUI interpolates the change via ShakeEffect.
    @State private var shakeAmounts: [UUID: CGFloat] = [:]

    // Which visual award scene to show — picked at random each round so the reward looks fresh.
    @State private var celebrationStyle: CelebrationView.Style = .flowers

    // File names of the praise and encouragement audio clips (without the .mp3 extension).
    // Place matching mp3 files in the Media/Sounds folder.
    // A random file is picked each round so the child hears a different phrase every time.
    private let praiseFiles    = ["win1", "win2", "win3", "win4", "win5", "win6", "win7", "win8", "win9"]
    private let encourageFiles = ["try1", "try2", "try3", "try4", "try5", "try6"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {

                // ── Prompt ────────────────────────────────────────────────────
                VStack(spacing: 14) {
                    Text("Who makes this sound?")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)

                    // Big speaker button so a child can replay the sound before answering.
                    Button {
                        soundPlayer.play(correctAnimal.assetName)
                    } label: {
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(correctAnimal.cardColor)
                            .padding(16)
                            .background(correctAnimal.cardColor.opacity(0.15))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Play the animal sound again")
                }
                .padding(.top, 8)

                // ── Choice cards ──────────────────────────────────────────────
                HStack(spacing: 12) {
                    ForEach(choices) { animal in
                        QuizChoiceCard(animal: animal)
                            // Scale the correct card up when the child gets it right.
                            .scaleEffect(showCelebration && animal.id == correctAnimal.id ? 1.15 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.4), value: showCelebration)
                            // Each card tracks its own shake counter so only the tapped
                            // wrong card wobbles, not all three.
                            .modifier(ShakeEffect(animatableData: shakeAmounts[animal.id, default: 0]))
                            .onTapGesture {
                                handleTap(animal)
                            }
                            // Merge the image and name label into one accessible button so
                            // VoiceOver announces the animal name and the tap action together.
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel(animal.name)
                            .accessibilityHint("Tap to choose \(animal.name.lowercased())")
                            .accessibilityAddTraits(.isButton)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Quiz")
            .navigationBarTitleDisplayMode(.large)
        }
        // The celebration sits outside the NavigationStack so it covers the full screen,
        // including the navigation bar, when the child gets the answer right.
        .overlay {
            if showCelebration {
                CelebrationView(style: celebrationStyle)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .accessibilityLabel("Correct! Great job! Next question coming up.")
            }
        }
        .onAppear {
            // Start a round only the first time the tab appears.
            // After the first round, rounds advance automatically when the child gets one right.
            if choices.isEmpty {
                startRound()
            }
        }
    }

    // Build a new question: pick a random correct animal, add two random wrong ones,
    // shuffle all three, and play the sound so the child hears it straight away.
    private func startRound() {
        let correct = Animal.all.randomElement()!
        // Filter out the correct animal so the wrong choices are always different from the answer.
        let wrongs = Animal.all.filter { $0.id != correct.id }.shuffled().prefix(2)

        correctAnimal = correct
        choices = ([correct] + wrongs).shuffled()
        showCelebration = false
        // Reset all shake counters so the new round's cards start still.
        shakeAmounts = [:]

        // Small delay so the view finishes laying out before the sound starts.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            soundPlayer.play(correct.assetName)
        }
    }

    // Called when the child taps one of the three choice cards.
    private func handleTap(_ animal: Animal) {
        // Ignore taps while the celebration is showing so the child enjoys the moment.
        guard !showCelebration else { return }

        if animal.id == correctAnimal.id {
            // Pick a new award scene at random so every win looks different.
            celebrationStyle = CelebrationView.Style.allCases.randomElement()!
            withAnimation(.easeInOut(duration: 0.25)) {
                showCelebration = true
            }
            // Small delay so the praise voice starts after the animal sound fades out
            // rather than colliding with it at the exact moment the child taps.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                soundPlayer.playFeedback(praiseFiles.randomElement()!)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                startRound()
            }
        } else {
            // Wrong — shake just this card so the child knows to try a different one.
            // Incrementing by 1 triggers one full shake cycle through ShakeEffect.
            withAnimation(.linear(duration: 0.5)) {
                shakeAmounts[animal.id, default: 0] += 1
            }
            // Small delay so the encouragement voice starts after the shake begins,
            // giving the animation a beat to register before the audio kicks in.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                soundPlayer.playFeedback(encourageFiles.randomElement()!)
            }
        }
    }
}

#Preview {
    QuizView()
        .environment(SoundPlayer())
}
