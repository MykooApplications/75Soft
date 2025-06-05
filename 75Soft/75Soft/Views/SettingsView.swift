//
//  SettingsView 2.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/5/25.
//


import SwiftUI
import WidgetKit

import SwiftUI

struct SettingsView: View {
    var viewModel: ChallengeViewModel

    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .bold()

            // Add actual settings UI here
            Text("Start Date: \(formatted(viewModel.state.startDate))")
            Text("Current Day: \(viewModel.state.currentDay)")
        }
        .padding()
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
