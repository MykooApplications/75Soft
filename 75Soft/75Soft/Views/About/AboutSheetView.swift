//
//  AboutSheetView.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/5/25.
//

import SwiftUI

struct AboutSheetView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // 🔹 Transparent black backdrop with slight blur
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            // 🔹 Centered Card
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }

                Text("What is 75 Soft?")
                    .font(.title2)
                    .bold()

                Text("""
                75 Soft is a 75-day discipline challenge where you commit to completing the same 4 healthy habits every day:

                • Drink 3L of water  
                • Read 10 pages  
                • Eat clean with no cheat meals  
                • Do one 45-minute workout

                If you miss any task, your streak resets to 0.
                """)
                    .font(.body)

                Spacer()
            }
            .padding()
            .frame(maxWidth: 340, maxHeight: 360)
            .background(.ultraThinMaterial) // ✅ Transparent blur effect
            .cornerRadius(20)
            .shadow(radius: 10)
        }
    }
}
