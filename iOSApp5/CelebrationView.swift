//
//  CelebrationView.swift
//  iOSApp5
//
//  Created by Etefworkie Melaku on 2026-07-09.
//
// Full-screen overlay shown when the child picks the correct animal in the quiz.
// Each call picks from four different award scenes so the reward looks and feels fresh every round.

import SwiftUI

struct CelebrationView: View {

    // Four visual themes — QuizView picks one at random each round.
    enum Style: CaseIterable {
        case flowers, stars, balloons, trophy

        var emojis: [String] {
            switch self {
            case .flowers:  return ["🌸", "🌷", "🌺", "🌻", "🌹", "🌼", "💐"]
            case .stars:    return ["⭐", "🌟", "✨", "💫", "🌠", "🎇", "⚡"]
            case .balloons: return ["🎈", "🎉", "🎊", "🎀", "🪅", "🎁", "🎏"]
            case .trophy:   return ["🏆", "🥇", "🎖️", "🏅", "👑", "💎", "⭐"]
            }
        }

        // The large central award icon shown in the middle of the screen.
        var award: String {
            switch self {
            case .flowers:  return "💐"
            case .stars:    return "🌟"
            case .balloons: return "🎊"
            case .trophy:   return "🏆"
            }
        }
    }

    let style: Style

    // Flips to true the moment the view appears, which triggers all particle and award animations.
    @State private var launched = false

    // Fixed horizontal offsets, stagger delays, and sizes for the 12 shower particles.
    // Spreading them across different x values with different delays creates the burst/shower
    // feeling without needing randomness (which could cause SwiftUI to re-render unpredictably).
    private let layout: [(x: CGFloat, delay: Double, size: CGFloat)] = [
        (-150, 0.00, 28), (-110, 0.10, 34), ( -70, 0.20, 24), (-30, 0.05, 38),
        (  30, 0.15, 30), (  70, 0.00, 26), ( 110, 0.25, 36), (150, 0.10, 28),
        (-130, 0.30, 32), ( -50, 0.35, 24), (  50, 0.28, 34), (130, 0.20, 28),
    ]

    var body: some View {
        ZStack {
            // Semi-transparent backdrop so the child can still see the quiz cards underneath.
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            // Particle shower — each emoji floats straight up from below center and fades out
            // as it rises, making it look like it flies off the top of the screen.
            ForEach(layout.indices, id: \.self) { i in
                Text(style.emojis[i % style.emojis.count])
                    .font(.system(size: layout[i].size))
                    .offset(x: layout[i].x, y: launched ? -430 : 180)
                    .opacity(launched ? 0 : 1)
                    .animation(
                        .easeOut(duration: 1.3).delay(layout[i].delay),
                        value: launched
                    )
            }

            // Central award pops in with a spring overshoot, then the "Amazing!" label
            // fades up underneath it with a short delay so it feels like a two-beat reveal.
            VStack(spacing: 16) {
                Text(style.award)
                    .font(.system(size: 100))
                    .scaleEffect(launched ? 1.15 : 0.2)
                    .rotationEffect(.degrees(launched ? 0 : -20))
                    .animation(.spring(response: 0.5, dampingFraction: 0.45), value: launched)

                Text("Amazing!")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.4), radius: 4)
                    .scaleEffect(launched ? 1.0 : 0.5)
                    .opacity(launched ? 1.0 : 0.0)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.6).delay(0.2),
                        value: launched
                    )
            }
        }
        .onAppear {
            launched = true
        }
    }
}

#Preview {
    CelebrationView(style: .flowers)
}
