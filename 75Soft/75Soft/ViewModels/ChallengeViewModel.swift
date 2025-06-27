import Foundation
import SwiftData
import WidgetKit

@Observable
class ChallengeViewModel {
    var entry: DailyEntry
    var state: ChallengeState
    private var modelContext: ModelContext
    
    init(entry: DailyEntry, state: ChallengeState, context: ModelContext) {
        self.entry = entry
        self.state = state
        self.modelContext = context
    }
    
    var tasks: [String: Bool] {
        [
            "💧 Drank 3L of Water": entry.waterCompleted,
            "📖 Read 10 Pages": entry.pagesRead,
            "🥗 No Cheating on Diet": entry.dietClean,
            "🏃‍♂️ 45 Mintes of Exercise": entry.workoutDone
        ]
    }
    
    /*
     Drank 3L of Water
     Read 10 Pages
     45 Mintes of Exercise
     No Cheating on Diet
     */
    
    func toggle(_ key: String) {
        switch key {
        case "💧 Drank 3L of Water":
            if !entry.waterCompleted { entry.waterCompleted = true }
        case "📖 Read 10 Pages":
            if !entry.pagesRead { entry.pagesRead = true }
        case "🥗 No Cheating on Diet":
            if !entry.dietClean { entry.dietClean = true }
        case "🏃‍♂️ 45 Mintes of Exercise":
            if !entry.workoutDone { entry.workoutDone = true }
        default: break
        }
        
        writeWidgetData(
            currentDay: state.currentDay,
            streak: state.streakCount,
            tasks: tasks
        )
        
        WidgetCenter.shared.reloadAllTimelines()
        
        checkCompletion()
        save()
    }
    
    func resetChallenge() {
        state.currentDay = 0          // reset to 0
        state.streakCount = 0
        state.lastCompletedDate = nil
        state.startDate = Date()
        state.resetCount += 1
        
        entry.waterCompleted = false
        entry.pagesRead = false
        entry.dietClean = false
        entry.workoutDone = false
        
        writeWidgetData(
            currentDay: 0, // ⬅️ match the reset value
            streak: 0,
            tasks: tasks
        )
        
        WidgetCenter.shared.reloadAllTimelines()
        save()
    }
    
    private func checkCompletion() {
        let allDone = entry.waterCompleted && entry.pagesRead && entry.dietClean && entry.workoutDone
        guard allDone else { return }
        
        // Only bump once per day
        if let last = state.lastCompletedDate, Calendar.current.isDateInToday(last) {
            return
        }
        
        // First time all tasks done → currentDay goes from 0 to 1
        state.currentDay += 1
        state.streakCount += 1
        state.lastCompletedDate = Date()
        
        writeWidgetData(
            currentDay: state.currentDay,
            streak: state.streakCount,
            tasks: tasks
        )
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func save() {
        try? modelContext.save()
    }
}
