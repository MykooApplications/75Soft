//
//  HistoryView.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/4/25.
//

import SwiftUI
import Charts
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    
    // Fetch daily entries sorted by date
    @Query(sort: [ SortDescriptor(\DailyEntry.date, order: .forward) ])
    private var entries: [DailyEntry]
    
    @Query private var state: [ChallengeState]
    
    private var challengeState: ChallengeState? { state.first }
    
    // MARK: - Computed Properties
    
    private var currentStreak: Int {
        challengeState?.currentDay ?? 0
    }
    
    private var totalCompleted: Int {
        entries.filter { entry in
            entry.waterCompleted &&
            entry.pagesRead &&
            entry.dietClean &&
            entry.workoutDone
        }
        .count
    }
    
    private var bestStreak: Int {
        var maxStreak = 0
        var running = 0
        for entry in entries.sorted(by: { $0.date < $1.date }) {
            if entry.waterCompleted && entry.pagesRead && entry.dietClean && entry.workoutDone {
                running += 1
                maxStreak = max(maxStreak, running)
            } else {
                running = 0
            }
        }
        return maxStreak
    }
    
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
    
    private var streakTrend: [Int] {
        var trend: [Int] = []
        var count = 0
        let sorted = entries.sorted { $0.date < $1.date }
        for entry in sorted {
            if entry.waterCompleted &&
                entry.pagesRead &&
                entry.dietClean &&
                entry.workoutDone
            {
                count += 1
            }
            trend.append(count)
        }
        return trend
    }
    
    private var taskRates: [(task: String, rate: Double)] {
        let totalDays = entries.count
        guard totalDays > 0 else { return [] }
        
        let waterRate   = Double(entries.filter { $0.waterCompleted }.count) / Double(totalDays)
        let readRate    = Double(entries.filter { $0.pagesRead }.count) / Double(totalDays)
        let dietRate    = Double(entries.filter { $0.dietClean }.count) / Double(totalDays)
        let workoutRate = Double(entries.filter { $0.workoutDone }.count) / Double(totalDays)
        
        return [
            ("💧 Water", waterRate),
            ("📖 Read", readRate),
            ("🥗 Diet", dietRate),
            ("🏃‍♂️ Workout", workoutRate)
        ]
    }
    
    struct Badge: Identifiable {
        let id = UUID()
        let title: String
        let unlocked: Bool
    }
    
    private var badges: [Badge] {
        [
            Badge(title: "7-Day Streak",   unlocked: currentStreak >=  7),
            Badge(title: "30-Day Streak",  unlocked: currentStreak >= 30),
            Badge(title: "75-Day Finish",  unlocked: currentStreak >= 75)
        ]
    }
    
    // MARK: - View State
    
    @State private var selectedView: ViewType = .calendar
    
    enum ViewType: String, CaseIterable, Identifiable {
        case calendar = "📆 Calendar"
        case charts   = "📊 Charts"
        var id: String { rawValue }
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Stats Cards
                // Stats Cards
                HStack(spacing: 16) {
                    StatCard(icon: "flame.fill", title: "Current Streak", value: "\(currentStreak)")
                        .frame(maxWidth: .infinity)               // fill half the screen
                        .aspectRatio(1.5, contentMode: .fit)      // wider than tall
                    
                    StatCard(icon: "checkmark.seal.fill", title: "Total Completed", value: "\(totalCompleted)")
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1.5, contentMode: .fit)
                    StatCard(icon: "star.fill", title: "Best Streak", value: "\(bestStreak)")
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1.5, contentMode: .fit)
                }
                .padding(.horizontal)
                
                // Toggle + Calendar/Charts
                VStack() {
                    Picker("View", selection: $selectedView) {
                        ForEach(ViewType.allCases) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if selectedView == .calendar, let challengeStart = challengeState?.startDate {
                        CalendarView(
                            completionByDate: completionByDate,
                            startDate: challengeStart
                        )
                        .frame(height: 250, alignment: .top)
                    } else {
                        ChartsView(streakTrend: streakTrend)
                            .frame(height: 250)
                    }
                }
                .padding(.horizontal)
                
                // Task Insights
                VStack(alignment: .leading, spacing: 8) {
                    Text("Task Insights").font(.headline)
                    ForEach(taskRates, id: \.task) { insight in
                        HStack {
                            Text(insight.task)
                            Spacer()
                            Text(String(format: "%.0f%%", insight.rate * 100))
                        }
                    }
                }
                .padding(.horizontal)
                
                // Achievements
                VStack(alignment: .leading, spacing: 8) {
                    Text("Achievements").font(.headline)
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

// MARK: - Supporting Views

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Image(systemName: icon).font(.title)
            Text(title).font(.caption)
            Text(value).font(.title2).bold()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}

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

struct BadgeView: View {
    let badge: HistoryView.Badge
    
    var body: some View {
        VStack {
            Image(systemName: badge.unlocked ? "award.fill" : "lock.fill")
                .font(.largeTitle)
                .foregroundColor(badge.unlocked ? .yellow : .gray)
            Text(badge.title).font(.caption)
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
