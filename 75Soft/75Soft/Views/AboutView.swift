//
//  AboutView 2.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/5/25.
//
import SwiftUI
import SwiftData
import WidgetKit

struct AboutView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About 75 Soft")
                .font(.largeTitle)
                .bold()
            Text("75 Soft is a 75-day challenge focusing on daily habits: hydration, reading, diet, and exercise. Complete all tasks daily to maintain your streak. Missing any resets your progress.")
                .font(.body)
            Spacer()
        }
        .padding()
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}
