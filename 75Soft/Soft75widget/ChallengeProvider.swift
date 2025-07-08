//
//  ChallengeProvider.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/4/25.
//
import WidgetKit
import SwiftUI
import SwiftData

// MARK: - The data our widget shows in each “timeline entry”
struct ChallengeEntry: TimelineEntry {
    let date: Date                // When this entry was created
    let currentDay: Int           // What day of the 75-day challenge we’re on
    let streakCount: Int          // How many days in a row have been completed
    let tasks: [String: Bool]     // A dictionary of tasks and whether they’re done
}

// MARK: - The provider that hands WidgetKit a fresh ChallengeEntry when it asks
struct ChallengeProvider: TimelineProvider {
    // Called to build a timeline of one or more entries
    func getTimeline(in context: Context, completion: @escaping (Timeline<ChallengeEntry>) -> Void) {
        let appGroupID = "group.com.roshanm.soft75"  // Your App Group ID
        // Where we wrote our shared JSON in the main app
        let fileURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent("widgetData.json")
        
        // Try to read & decode the JSON
        if let url = fileURL,
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode(SharedWidgetData.self, from: data) {
            
            // If that worked, make an entry with the real data
            let entry = ChallengeEntry(
                date: Date(),
                currentDay: decoded.currentDay,
                streakCount: decoded.streakCount,
                tasks: decoded.tasks
            )
            // We only need one entry, and we’ll refresh “atEnd”
            completion(Timeline(entries: [entry], policy: .atEnd))
            
        } else {
            // If reading failed, show a blank/fallback entry
            let fallback = ChallengeEntry(
                date: Date(),
                currentDay: 0,
                streakCount: 0,
                tasks: [
                    "💧 Water": false,
                    "📖 Read": false,
                    "🥗 Diet": false,
                    "🏃‍♂️ Workout": false
                ]
            )
            completion(Timeline(entries: [fallback], policy: .atEnd))
        }
    }
    
    // A simple placeholder shown while the real data loads
    func placeholder(in context: Context) -> ChallengeEntry {
        ChallengeEntry(
            date: Date(),
            currentDay: 1,
            streakCount: 0,
            tasks: [
                "💧 Drank 3L of Water": false,
                "📖 Read 10 Pages of a book": false,
                "🥗 Stuck to my diet": false,
                "🏃‍♂️ Completed 45 Min Workout": false
            ]
        )
    }
    
    // A quick “snapshot” for previews or the lock screen
    func getSnapshot(in context: Context, completion: @escaping (ChallengeEntry) -> Void) {
        let appGroupID = "group.com.roshanm.soft75"
        let url = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)!
            .appendingPathComponent("widgetData.json")
        
        let entry: ChallengeEntry
        if let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode(SharedWidgetData.self, from: data) {
            // Use real data if available
            entry = ChallengeEntry(
                date: Date(),
                currentDay: decoded.currentDay,
                streakCount: decoded.streakCount,
                tasks: decoded.tasks
            )
        } else {
            // Otherwise fall back
            entry = ChallengeEntry(
                date: Date(),
                currentDay: 1,
                streakCount: 0,
                tasks: [
                    "💧 Water": false,
                    "📖 Read": false,
                    "🥗 Diet": false,
                    "🏃‍♂️ Workout": false
                ]
            )
        }
        completion(entry)
    }
}

// MARK: - Small view that draws the circle and number
struct WidgetProgressView: View {
    let currentDay: Int
    
    // How “full” the circle should be (0.0…1.0)
    var progress: Double {
        min(Double(currentDay) / 75.0, 1.0)
    }
    
    var body: some View {
        ZStack {
            // Gray background circle
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 10)
            // Colored “trimmed” circle showing progress
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.accentColor,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90)) // start at top
            // Big number and “Day Streak” label
            VStack {
                Text("\(currentDay)")
                    .font(.title2)
                    .bold()
                Text("Day Streak")
                    .font(.caption2)
            }
        }
        .frame(width: 100, height: 100)
    }
}

// MARK: - Small view that lists each task with a little circle
struct WidgetChecklistView: View {
    var tasks: [String: Bool]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Sort keys so order is stable
            ForEach(tasks.sorted(by: { $0.key < $1.key }), id: \.key) { task, done in
                HStack(spacing: 6) {
                    // Little circle, filled if done
                    ZStack {
                        Circle()
                            .strokeBorder(done ? Color.accentColor : Color.gray, lineWidth: 2)
                            .frame(width: 14, height: 14)
                        if done {
                            Circle()
                                .fill(Color.accentColor)
                                .frame(width: 8, height: 8)
                        }
                    }
                    // Task name
                    Text(task)
                        .font(.caption2)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

// MARK: - The three widget configurations

// 1) Small circle-only widget
struct SmallProgressWidget: Widget {
    let kind = "SmallProgressWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ChallengeProvider()) { entry in
            WidgetProgressView(currentDay: entry.currentDay)
                .containerBackground(.background, for: .widget)
        }
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("75 Soft Progress")
        .description("Track your current streak.")
    }
}

// 2) Small checklist-only widget
struct SmallChecklistWidget: Widget {
    let kind = "SmallChecklistWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ChallengeProvider()) { entry in
            WidgetChecklistView(tasks: entry.tasks)
                .containerBackground(.background, for: .widget)
        }
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("75 Soft Tasks")
        .description("See today’s checklist.")
    }
}

// 3) Medium widget with both circle + list
struct MediumComboWidget: Widget {
    let kind = "MediumComboWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ChallengeProvider()) { entry in
            HStack(alignment: .center) {
                WidgetProgressView(currentDay: entry.currentDay)
                Spacer()
                WidgetChecklistView(tasks: entry.tasks)
            }
            .containerBackground(.background, for: .widget)
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("75 Soft Overview")
        .description("Track progress and checklist together.")
    }
}

// MARK: - Bundle that groups all three widgets
@main
struct Soft75WidgetBundle: WidgetBundle {
    var body: some Widget {
        SmallProgressWidget()
        SmallChecklistWidget()
        MediumComboWidget()
    }
}
