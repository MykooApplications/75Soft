//
//  HistoryViewModel.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/26/25.
//
import Foundation
import SwiftData
import WidgetKit

// This little coach gathers all the numbers and data we’ll show on the History screen.
class HistoryViewModel: ObservableObject {
    // 🔥 How many days in a row you’ve kept your streak going
    @Published var currentStreak: Int = 10
    
    // ✅ How many days total you’ve fully completed all your tasks
    @Published var totalCompleted: Int = 45
    
    // 📆 For the past 30 days, did you finish every task? true = yes, false = no
    @Published var completionByDate: [Date: Bool] = {
        var dict: [Date: Bool] = [:]
        let calendar = Calendar.current
        let today = Date()
        // We’re faking data here by picking a random yes/no for each of the last 30 days
        for offset in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -offset, to: today) {
                dict[date] = Bool.random()
            }
        }
        return dict
    }()
    
    // 📈 A simple list of numbers 1 through 30 showing how your streak grew each day
    var streakTrend: [Int] {
        Array(stride(from: 1, through: 30, by: 1).map { $0 })
    }
    
    // 📊 How often you hit each individual task, as a percentage
    @Published var taskRates: [(task: String, rate: Double)] = [
        ("💧 Water", 0.93),    // You hit water 93% of the time
        ("📖 Read", 0.85),     // You read 85% of the time
        ("🥗 Diet", 0.78),     // You ate clean 78% of the time
        ("🏃‍♂️ Workout", 0.88) // You exercised 88% of the time
    ]
    
    // 🏅 Badges you can earn for hitting streak milestones
    struct Badge: Identifiable {
        let id = UUID()
        let title: String       // e.g. "7-Day Streak"
        let unlocked: Bool      // true = you earned it, false = still locked
    }
    
    // 📜 A few example badges, some unlocked, some still locked
    @Published var badges: [Badge] = [
        Badge(title: "7-Day Streak", unlocked: true),
        Badge(title: "30-Day Streak", unlocked: false),
        Badge(title: "75-Day Finish", unlocked: false)
    ]
}
