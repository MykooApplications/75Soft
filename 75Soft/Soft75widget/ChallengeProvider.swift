//
//  75SoftWidget.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/4/25.
//
import WidgetKit
import SwiftUI
import SwiftData

struct ChallengeEntry: TimelineEntry {
    let date: Date
    let currentDay: Int
    let streakCount: Int
    let tasks: [String: Bool]
}

struct ChallengeProvider: TimelineProvider {
    func getTimeline(in context: Context, completion: @escaping (Timeline<ChallengeEntry>) -> Void) {
        let appGroupID = "group.com.roshanm.soft75" // use your actual value
        let fileURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent("widgetData.json")

        if let url = fileURL,
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode(SharedWidgetData.self, from: data) {

           // print("✅ Widget read data: \(decoded)")
            
            let entry = ChallengeEntry(
                date: Date(),
                currentDay: decoded.currentDay,
                streakCount: decoded.streakCount,
                tasks: decoded.tasks
            )
            completion(Timeline(entries: [entry], policy: .atEnd))

        } else {
            //print("❌ Widget failed to read or decode JSON")
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

    func getSnapshot(in context: Context, completion: @escaping (ChallengeEntry) -> Void) {
        let fm = FileManager.default
        let url = fm
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.roshanm.soft75")!
            .appendingPathComponent("widgetData.json")

        var entry: ChallengeEntry

        if let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode(SharedWidgetData.self, from: data) {
            entry = ChallengeEntry(
                date: Date(),
                currentDay: decoded.currentDay,
                streakCount: decoded.streakCount,
                tasks: decoded.tasks
            )
        } else {
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

struct WidgetProgressView: View {
    let currentDay: Int

    var progress: Double {
        min(Double(currentDay) / 75.0, 1.0)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 10)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
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

struct WidgetChecklistView: View {
    var tasks: [String: Bool]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(tasks.sorted(by: { $0.key < $1.key }), id: \.key) { task, done in
                HStack(spacing: 6) {
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

// Widget 1: Small Progress Only
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

// Widget 2: Small Checklist Only
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

// Widget 3: Medium Combined
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

@main
struct Soft75WidgetBundle: WidgetBundle {
    var body: some Widget {
        SmallProgressWidget()
        SmallChecklistWidget()
        MediumComboWidget()
    }
}
