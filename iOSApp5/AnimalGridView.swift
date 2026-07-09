//
//  AnimalGridView.swift
//  iOSApp5
//
//  Created by Etefworkie Melaku on 2026-07-09.
//

import SwiftUI

struct AnimalGridView: View {
    // Two equally-sized columns that stretch to fill the available screen width.
    // The spacing value here controls the gap between columns; the LazyVGrid spacing
    // parameter below controls the gap between rows.
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        // NavigationStack lives here so every card's NavigationLink has a stack to push onto.
        NavigationStack {
            ScrollView {
                // LazyVGrid only creates card views as they scroll into view,
                // which keeps memory usage low even if the animal list grows later.
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(Animal.all) { animal in
                        AnimalCardView(animal: animal)
                    }
                }
                .padding(16)
            }
            .navigationTitle("Animal Friends")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    AnimalGridView()
        .environment(SoundPlayer())
}
