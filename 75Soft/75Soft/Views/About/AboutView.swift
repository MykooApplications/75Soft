//
//  AboutView.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/5/25.
//
import SwiftUI
import SwiftData
import WidgetKit

// This view shows a simple “About” screen inside your app’s navigation.
// It explains what 75 Soft is and how it works.
struct AboutView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // 📘 Big heading at the top
            Text("About 75 Soft")
                .font(.largeTitle)  // make the text big
                .bold()             // make it bold so it stands out
            
            // 📝 A friendly sentence explaining the challenge
            Text("""
                 75 Soft is a 75-day challenge focusing on daily habits:
                 hydration, reading, diet, and exercise.
                 Complete all tasks daily to maintain your streak.
                 Missing any resets your progress.
                 """)
            .font(.body)       // normal paragraph text
            
            Spacer()              // push everything up, leaving empty space below
        }
        .padding()                // add some space around the edges
        .navigationTitle("About") // show “About” in the navigation bar
        .navigationBarTitleDisplayMode(.inline) // keep the title small & inline
    }
}
