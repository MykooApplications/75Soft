//
//  ChecklistView.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/4/25.
//

import SwiftUI
import SwiftData

struct ChecklistView: View {
    @Bindable var entry: DailyEntry
    @Environment(\.modelContext) private var modelContext
    @Query private var state: [ChallengeState]

    var body: some View {
        Form {
            Toggle("3L of Water", isOn: $entry.waterCompleted)
            Toggle("10 Pages Read", isOn: $entry.pagesRead)
            Toggle("Clean Diet", isOn: $entry.dietClean)
            Toggle("45 Min Workout", isOn: $entry.workoutDone)
        }
        .onDisappear {
            checkCompletion()
        }
    }

    private func checkCompletion() {
        if entry.waterCompleted && entry.pagesRead && entry.dietClean && entry.workoutDone {
            if let challenge = state.first {
                challenge.streakCount += 1
                challenge.currentDay += 1
                challenge.lastCompletedDate = Date()
            }
        }
    }
}
