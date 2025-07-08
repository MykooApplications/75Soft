//
//  HistoryView.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/4/25.
//

import SwiftUI
import Charts
import SwiftData

// The main History screen that shows your progress over time.
struct HistoryView: View {
    // We need the SwiftData context to fetch and save data.
    @Environment(\.modelContext) private var modelContext
    
    // 1) Fetch all daily entries, sorted by earliest date first.
    @Query(sort: [ SortDescriptor(\DailyEntry.date, order: .forward) ])
    private var entries: [DailyEntry]
    
    // 2) Fetch the single ChallengeState (there’s only one).
    @Query private var state: [ChallengeState]
    
    // Helper to grab that one ChallengeState object.
    private var challengeState: ChallengeState? { state.first }
    
    // MARK: – Computed stats
    
    // How many days in a row you’ve currently completed.
    private var currentStreak: Int {
        challengeState?.currentDay ?? 0
    }
    
    // Total number of days (entries) where you did all four tasks.
    private var totalCompleted: Int {
        entries.filter { entry in
            entry.waterCompleted &&
            entry.pagesRead &&
            entry.dietClean &&
            entry.workoutDone
        }
        .count
    }
    
    // Your best streak ever—longest run of consecutive fully completed days.
    private var bestStreak: Int {
        var maxStreak = 0
        var running = 0
        for entry in entries.sorted(by: { $0.date < $1.date }) {
            // If you did everything today, add 1 to your running streak
            if entry.waterCompleted &&
                entry.pagesRead &&
                entry.dietClean &&
                entry.workoutDone {
                running += 1
                maxStreak = max(maxStreak, running)
            } else {
                // Otherwise, reset the running count to 0
                running = 0
            }
        }
        return maxStreak
    }
    
    // A dictionary mapping each calendar day to `true` if fully done, `false` if not
    private var completionByDate: [Date: Bool] {
        Dictionary(
            uniqueKeysWithValues: entries.map { entry in
                let day = Calendar.current.startOfDay(for: entry.date)
                let done = entry.waterCompleted &&
                entry.pagesRead &&
                entry.dietClean &&
                entry.workoutDone
                return (day, done)
            }
        )
    }
    
    // An array that shows how your streak grew day by day (for charting)
    private var streakTrend: [Int] {
        var trend: [Int] = []
        var count = 0
        let sorted = entries.sorted { $0.date < $1.date }
        for entry in sorted {
            if entry.waterCompleted &&
                entry.pagesRead &&
                entry.dietClean &&
                entry.workoutDone {
                count += 1 // still going
            }
            trend.append(count)
        }
        return trend
    }
    
    // How often you completed each individual task (for “Task Insights”)
    private var taskRates: [(task: String, rate: Double)] {
        let totalDays = entries.count
        guard totalDays > 0 else { return [] }
        
        let waterRate   = Double(entries.filter { $0.waterCompleted }.count) / Double(totalDays)
        let readRate    = Double(entries.filter { $0.pagesRead }.count)     / Double(totalDays)
        let dietRate    = Double(entries.filter { $0.dietClean }.count)     / Double(totalDays)
        let workoutRate = Double(entries.filter { $0.workoutDone }.count)   / Double(totalDays)
        
        return [
            ("💧 Water", waterRate),
            ("📖 Read",   readRate),
            ("🥗 Diet",   dietRate),
            ("🏃‍♂️ Workout", workoutRate)
        ]
    }
    
    // Tiny Badge model: a name and whether you’ve unlocked it
    struct Badge: Identifiable {
        let id = UUID()
        let title: String
        let unlocked: Bool
    }
    
    // The list of badges based on your current streak
    private var badges: [Badge] {
        [
            Badge(title: "7-Day Streak",  unlocked: currentStreak >=  7),
            Badge(title: "30-Day Streak", unlocked: currentStreak >= 30),
            Badge(title: "75-Day Finish", unlocked: currentStreak >= 75)
        ]
    }
    
    // MARK: – UI State
    
    // Which view tab is selected: calendar or charts?
    @State private var selectedView: ViewType = .calendar
    
    enum ViewType: String, CaseIterable, Identifiable {
        case calendar = "📆 Calendar"
        case charts   = "📊 Charts"
        var id: String { rawValue }
    }
    
    // MARK: – View Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // 1) Stats Cards at the top
                HStack(spacing: 16) {
                    StatCard(
                        icon: "flame.fill",
                        title: "Current Streak",
                        value: "\(currentStreak)"
                    )
                    StatCard(
                        icon: "checkmark.seal.fill",
                        title: "Total Completed",
                        value: "\(totalCompleted)"
                    )
                    StatCard(
                        icon: "star.fill",
                        title: "Best Streak",
                        value: "\(bestStreak)"
                    )
                }
                .padding(.horizontal)
                
                // 2) Toggle between Calendar and Charts
                VStack(spacing: 8) {
                    Picker("View", selection: $selectedView) {
                        ForEach(ViewType.allCases) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if selectedView == .calendar,
                       let challengeStart = challengeState?.startDate {
                        // Calendar view
                        CalendarView(
                            completionByDate: completionByDate,
                            startDate: challengeStart
                        )
                        .frame(height: 250, alignment: .top)
                    } else {
                        // Charts view
                        ChartsView(streakTrend: streakTrend)
                            .frame(height: 250)
                    }
                }
                .padding(.horizontal)
                
                // 3) Task Insights list
                VStack(alignment: .leading, spacing: 8) {
                    Text("Task Insights")
                        .font(.headline)
                    ForEach(taskRates, id: \.task) { insight in
                        HStack {
                            Text(insight.task)
                            Spacer()
                            Text(String(format: "%.0f%%", insight.rate * 100))
                        }
                    }
                }
                .padding(.horizontal)
                
                // 4) Achievements badges
                VStack(alignment: .leading, spacing: 8) {
                    Text("Achievements")
                        .font(.headline)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(badges) { badge in
                                BadgeView(badge: badge)
                            }
                        }
                        .padding(.vertical)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: – StatCard: shows an icon, a title, and a big number
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title)
            Text(title)
                .font(.caption)
            Text(value)
                .font(.title2)
                .bold()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}

// MARK: – ChartsView: line chart of your streak over time
struct ChartsView: View {
    let streakTrend: [Int]
    
    var body: some View {
        Chart {
            ForEach(Array(streakTrend.enumerated()), id: \.offset) { idx, value in
                LineMark(
                    x: .value("Day", idx + 1),
                    y: .value("Streak", value)
                )
            }
        }
        .chartXAxisLabel("Day")
        .chartYAxisLabel("Streak")
    }
}

// MARK: – BadgeView: small card showing an achievement badge
struct BadgeView: View {
    let badge: HistoryView.Badge
    
    var body: some View {
        VStack {
            Image(systemName: badge.unlocked ? "award.fill" : "lock.fill")
                .font(.largeTitle)
                .foregroundColor(badge.unlocked ? .yellow : .gray)
            Text(badge.title)
                .font(.caption)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
        .shadow(radius: badge.unlocked ? 2 : 0)
    }
}

// Preview
struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HistoryView()
        }
    }
}
