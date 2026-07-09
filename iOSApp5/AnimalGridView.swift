//
//  AnimalGridView.swift
//  iOSApp5
//
//  Created by Etefworkie Melaku on 2026-07-09.
//
// The Animals tab. Shows all 8 animal cards in a 2-column scrollable grid.
// Owns the NavigationStack so cards can push the detail screen without the TabView getting involved.

import SwiftUI

struct AnimalGridView: View {
    // Two equally-sized columns that stretch to fill the available screen width.
    // The spacing value here controls the gap between columns; the LazyVGrid spacing
    // parameter below controls the gap between rows.
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    // Tracks whether the grid has appeared for the first time.
    // Flipping this to true triggers the staggered card entrance animation.
    @State private var appeared = false

    var body: some View {
        // NavigationStack lives here so every card's NavigationLink has a stack to push onto.
        NavigationStack {
            ScrollView {
                // LazyVGrid only creates card views as they scroll into view,
                // which keeps memory usage low even if the animal list grows later.
                // enumerated() gives each card its position so we can stagger the animation.
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(Array(Animal.all.enumerated()), id: \.element.id) { index, animal in
                        AnimalCardView(animal: animal)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)
                            // Each card waits a little longer than the previous one to pop in,
                            // creating a wave effect across the grid.
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.75)
                                    .delay(Double(index) * 0.06),
                                value: appeared
                            )
                    }
                }
                .padding(16)
            }
            .navigationTitle("Animal Friends")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                // opacity and offset both start at their hidden values so the first
                // render is invisible; setting appeared = true fires all the animations.
                appeared = true
            }
        }
    }
}

#Preview {
    AnimalGridView()
        .environment(SoundPlayer())
}
