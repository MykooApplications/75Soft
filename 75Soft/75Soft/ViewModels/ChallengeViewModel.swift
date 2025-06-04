//
//  ChallengeViewModel.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/4/25.
//


import Foundation
import WidgetKit
import SwiftData

@Observable
class ChallengeViewModel {
    var entry: DailyEntry
    var state: ChallengeState

    init(entry: DailyEntry, state: ChallengeState) {
        self.entry = entry
        self.state = state
    }

    var tasks: [String: Bool] {
        [
            "💧 Water": entry.waterCompleted,
            "📖 Read": entry.pagesRead,
            "🥗 Diet": entry.dietClean,
            "🏃‍♂️ Workout": entry.workoutDone
        ]
    }

    func toggle(_ key: String) {
        switch key {
        case "💧 Water": entry.waterCompleted.toggle()
        case "📖 Read": entry.pagesRead.toggle()
        case "🥗 Diet": entry.dietClean.toggle()
        case "🏃‍♂️ Workout": entry.workoutDone.toggle()
        default: break
        }

        checkCompletion()
    }

    private func checkCompletion() {
        let allDone = entry.waterCompleted && entry.pagesRead && entry.dietClean && entry.workoutDone

        guard allDone else { return }

        if let last = state.lastCompletedDate, Calendar.current.isDateInToday(last) {
            return // Already updated today
        }

        state.streakCount += 1
        state.currentDay += 1
        state.lastCompletedDate = Date()

        writeWidgetData(currentDay: state.currentDay, streak: state.streakCount, tasks: tasks)
        WidgetCenter.shared.reloadAllTimelines()
    }
}