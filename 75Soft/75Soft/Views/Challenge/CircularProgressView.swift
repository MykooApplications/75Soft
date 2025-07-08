//
//  CircularProgressView.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/4/25.
//
import SwiftUI

// A big, round progress meter showing how many days you’ve completed out of 75.
struct CircularProgressView: View {
    // The day number you’re on (e.g. Day 5)
    let currentDay: Int

    // Convert currentDay into a percentage from 0.0 up to 1.0
    // We use “min” so it never goes beyond 100% (1.0).
    private var progress: Double {
        min(Double(currentDay) / 75.0, 1.0)
    }

    var body: some View {
        ZStack {
            // 1) Background circle in a light gray—this is the “track”
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 20)

            // 2) Foreground circle trimmed to show only the part we’ve completed
            Circle()
                .trim(from: 0, to: progress)         // show up to “progress” percent
                .stroke(                              // stroke with a rounded cap
                    Color.accentColor,
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))        // start at the top instead of the right
                .animation(.easeInOut(duration: 0.5), // animate changes smoothly
                           value: progress)

            // 3) In the center, show the day number and label
            VStack {
                Text("\(currentDay)")
                    .font(.largeTitle)  // big, bold number
                    .bold()
                Text("Day Streak")
                    .font(.caption)     // smaller label underneath
            }
        }
        // Make the whole thing stretch out horizontally if it can
        .frame(maxWidth: .infinity)
        .padding() // give it some breathing room from other views
    }
}
