//
//  ChallengeViewModel.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/4/25.
//

import SwiftUI
import WidgetKit
import SwiftData

// This class is like your personal coach in code form.
// It watches what you do each day, keeps track of your streak,
// and tells the app (and its widget) when to update.
class ChallengeViewModel: ObservableObject {
    // The checklist for *today* (did you drink, read, eat clean, workout?)
    @Published var entry: DailyEntry
    // The overall challenge details (start date, streak length, resets, forgiveness settings)
    @Published var state: ChallengeState
    
    // This is how we save and load from our SwiftData database
    private let modelContext: ModelContext
    
    // When we make a new coach, we hand it today’s entry, the challenge state, and the database context
    init(entry: DailyEntry, state: ChallengeState, context: ModelContext) {
        self.entry = entry
        self.state = state
        self.modelContext = context
    }
    
    // A handy dictionary listing each task name and whether YOU did it today
    var tasks: [String: Bool] {
        [
            "💧 Drank 3L of Water": entry.waterCompleted,
            "📖 Read 10 Pages": entry.pagesRead,
            "🥗 No Cheating on Diet": entry.dietClean,
            "🏃‍♂️ 45 Minutes of Exercise": entry.workoutDone
        ]
    }
    
    // This flips a task from “not done” to “done,” but only once
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
        
        // After each toggle, see if you’ve now completed *everything* for today
        checkCompletion()
        // And save your progress
        save()
    }
    
    // This completely restarts your challenge from scratch
    func resetChallenge() {
        // Reset all the streak numbers
        state.streakCount = 0
        state.currentDay = 1         // Day 1 is the first full day you’ll do
        state.lastCompletedDate = nil
        state.startDate = Date()     // Starts *today* now
        state.resetCount += 1        // Track how many times you’ve reset
        
        // And undo today’s checklist so tomorrow you start fresh
        entry.waterCompleted = false
        entry.pagesRead      = false
        entry.dietClean      = false
        entry.workoutDone    = false
        
        // Let the widget know, too
        writeWidgetData(
            currentDay: state.currentDay,
            streak: state.streakCount,
            tasks: tasks
        )
        WidgetCenter.shared.reloadAllTimelines()
        save()
    }
    
    // Called after every task toggle to see if the entire day is done,
    // and if so, whether your streak should go up or be reset.
    private func checkCompletion() {
        // Are all four tasks done?
        let allDone =
        entry.waterCompleted &&
        entry.pagesRead &&
        entry.dietClean &&
        entry.workoutDone
        
        // If not everything’s done, bail out early
        guard allDone else { return }
        
        // If they already finished today, do nothing more
        if let last = state.lastCompletedDate,
           Calendar.current.isDateInToday(last) {
            return
        }
        
        // If they skipped more than just yesterday…
        if let last = state.lastCompletedDate,
           !Calendar.current.isDateInYesterday(last) {
            
            // If we’re forgiving a missed day, just pretend yesterday was done
            if state.forgiveMissedDay {
                state.lastCompletedDate = Calendar.current.date(
                    byAdding: .day,
                    value: -1,
                    to: Date()
                )
                save()
                return
            }
            
            // Otherwise we really missed too many days, so reset
            resetChallenge()
            return
        }
        
        // It’s a brand-new day and not a “skip,” so bump the streak
        state.streakCount += 1
        state.currentDay  += 1
        state.lastCompletedDate = Date()
        
        // Update the widget with the new streak info
        writeWidgetData(
            currentDay: state.currentDay,
            streak: state.streakCount,
            tasks: tasks
        )
        WidgetCenter.shared.reloadAllTimelines()
        save()
    }
    
    // Saves our SwiftData database so nothing gets lost
    func save() {
        try? modelContext.save()
    }
    
    // A little helper that lets you jump to “Day X” for testing
    func jumpToDay(_ day: Int) {
        let start = state.startDate
        // Pretend we’re on day X
        state.currentDay = day
        state.streakCount = day
        // And pretend we completed that day
        state.lastCompletedDate = Calendar.current.date(
            byAdding: .day,
            value: day - 1,
            to: start
        )
        
        // Tell the widget to show “all tasks done” for that day
        writeWidgetData(
            currentDay: state.currentDay,
            streak: state.streakCount,
            tasks: Dictionary(
                uniqueKeysWithValues: tasks.map { ($0.key, true) }
            )
        )
        WidgetCenter.shared.reloadAllTimelines()
        save()
    }
}
