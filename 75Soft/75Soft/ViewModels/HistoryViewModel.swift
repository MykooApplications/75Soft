//
//  HistoryViewModel.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/26/25.
//
import Foundation
import SwiftData
import WidgetKit

/// ViewModel for History Screen
class HistoryViewModel: ObservableObject {
    @Published var currentStreak: Int = 10
    @Published var totalCompleted: Int = 45

    @Published var completionByDate: [Date: Bool] = {
        var dict: [Date: Bool] = [:]
        let calendar = Calendar.current
        let today = Date()
        for offset in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -offset, to: today) {
                dict[date] = Bool.random()
            }
        }
        return dict
    }()

    var streakTrend: [Int] {
        Array(stride(from: 1, through: 30, by: 1).map { $0 })
    }
    @Published var taskRates: [(task: String, rate: Double)] = [
        ("💧 Water", 0.93),
        ("📖 Read", 0.85),
        ("🥗 Diet", 0.78),
        ("🏃‍♂️ Workout", 0.88)
    ]

    struct Badge: Identifiable {
        let id = UUID()
        let title: String
        let unlocked: Bool
    }
    @Published var badges: [Badge] = [
        Badge(title: "7-Day Streak", unlocked: true),
        Badge(title: "30-Day Streak", unlocked: false),
        Badge(title: "75-Day Finish", unlocked: false)
    ]
}
