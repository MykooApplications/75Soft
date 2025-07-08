//
//  AboutSheetView.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/5/25.
//

import SwiftUI

struct AboutSheetView: View {
    // This lets us close the sheet when the little “X” button is tapped.
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // 1) Dark, see-through background so you know you’re on a pop-up
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            // 2) The white/blur card in the middle
            VStack(alignment: .leading, spacing: 16) {
                // 2a) Top row with a close (X) button
                HStack {
                    Spacer() // push the X to the right
                    Button(action: {
                        dismiss() // “poof”—close me!
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
                
                // 2b) Big heading
                Text("What is 75 Soft?")
                    .font(.title2)
                    .bold()
                
                // 2c) Explanatory text with bullet points
                Text("""
                75 Soft is a 75-day discipline challenge where you commit to completing the same 4 healthy habits every day:
                
                • Drink 3L of water  
                • Read 10 pages  
                • Eat clean with no cheat meals  
                • Do one 45-minute workout
                
                If you miss any task, your streak resets to 0.
                """)
                .font(.body)
                
                Spacer() // push content to the top of the card
            }
            .padding() // add some breathing room inside the card
            .frame(maxWidth: 340, maxHeight: 360)
            .background(.ultraThinMaterial) // frosted-glass effect
            .cornerRadius(20)                // round the corners
            .shadow(radius: 10)              // gentle drop shadow
        }
    }
}
