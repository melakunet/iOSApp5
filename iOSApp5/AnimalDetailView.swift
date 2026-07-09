//
//  AnimalDetailView.swift
//  iOSApp5
//
//  Created by Etefworkie Melaku on 2026-07-09.
//

import SwiftUI
import AVKit

struct AnimalDetailView: View {
    let animal: Animal

    // Pull the shared sound player from the environment so the "Hear me!" button
    // uses the same player as the grid — no overlapping audio sessions.
    @Environment(SoundPlayer.self) private var soundPlayer

    // We create the video player once in init so it is ready the moment the view appears.
    // AVPlayer is a class (reference type), so a let constant is fine — we can still
    // call pause() on it even though the reference itself never changes.
    private let player: AVPlayer?

    init(animal: Animal) {
        self.animal = animal
        // Look up the mp4 in the bundle. If the file is missing, player stays nil
        // and the body shows a friendly placeholder instead of crashing.
        if let url = Bundle.main.url(forResource: animal.assetName, withExtension: "mp4") {
            self.player = AVPlayer(url: url)
        } else {
            self.player = nil
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // ── Fun fact ─────────────────────────────────────────────────
                VStack(alignment: .leading, spacing: 6) {
                    Text("Did you know?")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)

                    Text(animal.fact)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        // fixedSize lets the text grow as many lines as it needs
                        // instead of being clipped by the scroll view's width.
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal)

                // ── Video player ──────────────────────────────────────────────
                if let player {
                    // VideoPlayer shows the system's native transport controls automatically.
                    // We never call player.play() here, so it starts paused —
                    // the child taps the Play button when they are ready.
                    VideoPlayer(player: player)
                        .aspectRatio(16 / 9, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                        .accessibilityLabel("\(animal.name) video")
                } else {
                    // Friendly stand-in when the video file hasn't landed in the bundle yet.
                    RoundedRectangle(cornerRadius: 16)
                        .fill(animal.cardColor.opacity(0.15))
                        .aspectRatio(16 / 9, contentMode: .fit)
                        .overlay {
                            VStack(spacing: 10) {
                                Image(systemName: "video.slash")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.secondary)
                                Text("Video coming soon!")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal)
                        .accessibilityLabel("Video for \(animal.name) is not yet available")
                }

                // ── "Hear me!" button ─────────────────────────────────────────
                // Replaying the sound here means a child on this screen can hear
                // the animal call again without going back to the grid.
                Button {
                    soundPlayer.play(animal.assetName)
                } label: {
                    Label("Hear me!", systemImage: "speaker.wave.2.fill")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(animal.cardColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal)
                .accessibilityLabel("Hear the \(animal.name.lowercased()) sound again")
            }
            .padding(.vertical)
        }
        .navigationTitle(animal.name)
        .navigationBarTitleDisplayMode(.large)
        .onDisappear {
            // Pause the video when the user navigates back so its audio doesn't keep
            // playing behind the grid screen.
            player?.pause()
        }
    }
}

#Preview {
    NavigationStack {
        AnimalDetailView(animal: Animal.all[0])
            .environment(SoundPlayer())
    }
}
