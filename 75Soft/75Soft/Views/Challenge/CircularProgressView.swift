//
//  CircularProgressView.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/4/25.
//
import SwiftUI

struct CircularProgressView: View {
    let currentDay: Int

    var progress: Double {
        min(Double(currentDay) / 75.0, 1.0)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 20)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            VStack {
                Text("\(currentDay)")
                    .font(.largeTitle)
                    .bold()
                Text("Day Streak")
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}
