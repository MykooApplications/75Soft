// ChallengeViewModel.swift
// 75Soft

// ChallengeViewModel.swift
// 75Soft

import SwiftUI
import WidgetKit
import SwiftData

/// ViewModel managing the challenge state and daily entry logic
class ChallengeViewModel: ObservableObject {
    @Published var entry: DailyEntry
    @Published var state: ChallengeState

    private let modelContext: ModelContext

    init(entry: DailyEntry, state: ChallengeState, context: ModelContext) {
        self.entry = entry
        self.state = state
        self.modelContext = context
    }

    /// Current task completion mapping
    var tasks: [String: Bool] {
        [
            "💧 Drank 3L of Water": entry.waterCompleted,
            "📖 Read 10 Pages": entry.pagesRead,
            "🥗 No Cheating on Diet": entry.dietClean,
            "🏃‍♂️ 45 Minutes of Exercise": entry.workoutDone
        ]
    }

    /// Toggle a task on if it hasn't been completed already
    func toggle(_ key: String) {
        switch key {
        case "💧 Drank 3L of Water":
            if !entry.waterCompleted { entry.waterCompleted = true }
        case "📖 Read 10 Pages":
            if !entry.pagesRead { entry.pagesRead = true }
        case "🥗 No Cheating on Diet":
            if !entry.dietClean { entry.dietClean = true }
        case "🏃‍♂️ 45 Minutes of Exercise":
            if !entry.workoutDone { entry.workoutDone = true }
        default:
            break
        }

        checkCompletion()
        save()
    }

    /// Reset the entire challenge and today's entry
    func resetChallenge() {
        state.streakCount = 0
        state.currentDay = 1
        state.lastCompletedDate = nil
        state.startDate = Date()
        state.resetCount += 1

        entry.waterCompleted = false
        entry.pagesRead = false
        entry.dietClean = false
        entry.workoutDone = false

        writeWidgetData(
            currentDay: state.currentDay,
            streak: state.streakCount,
            tasks: tasks
        )
        WidgetCenter.shared.reloadAllTimelines()
        save()
    }

    /// Check if all tasks are done and update streak
    private func checkCompletion() {
        let allDone =
            entry.waterCompleted &&
            entry.pagesRead &&
            entry.dietClean &&
            entry.workoutDone

        guard allDone else { return }

        // Only increment once per day
        if let lastDate = state.lastCompletedDate,
           Calendar.current.isDateInToday(lastDate) {
            return
        }

        state.streakCount += 1
        state.currentDay += 1
        state.lastCompletedDate = Date()

        writeWidgetData(
            currentDay: state.currentDay,
            streak: state.streakCount,
            tasks: tasks
        )
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Persist SwiftData context
    private func save() {
        try? modelContext.save()
    }
}
