//
//  QuizView.swift
//  iOSApp5
//
//  Created by Etefworkie Melaku on 2026-07-09.
//
// The Quiz tab. Plays a random animal sound and shows 3 image choices for the child to pick.
// Correct tap triggers a spring celebration; wrong tap shakes only the tapped card.

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

    // True while the "Great job!" celebration is showing after a correct answer.
    @State private var showCelebration = false

    // Each card has its own shake counter so wrong taps on different cards animate independently.
    // Incrementing a value triggers a new shake; SwiftUI interpolates the change via ShakeEffect.
    @State private var shakeAmounts: [UUID: CGFloat] = [:]

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

                // ── Celebration ───────────────────────────────────────────────
                // Pops in after a correct tap and disappears when the next round starts.
                if showCelebration {
                    VStack(spacing: 6) {
                        Text("🎉")
                            .font(.system(size: 72))
                        Text("Great job!")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.green)
                    }
                    .transition(.scale(scale: 0.5).combined(with: .opacity))
                    .accessibilityLabel("Correct! Great job! Next question coming up.")
                }

                Spacer()
            }
            // A single animation drives the celebration appearing and disappearing.
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showCelebration)
            .navigationTitle("Quiz")
            .navigationBarTitleDisplayMode(.large)
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
            // Correct! Show the celebration then automatically load the next round.
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                showCelebration = true
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
        }
    }
}

#Preview {
    QuizView()
        .environment(SoundPlayer())
}
