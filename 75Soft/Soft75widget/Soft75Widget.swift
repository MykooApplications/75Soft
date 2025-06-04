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
}

struct ChallengeProvider: TimelineProvider {
    func placeholder(in context: Context) -> ChallengeEntry {
        ChallengeEntry(date: Date(), currentDay: 1, streakCount: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (ChallengeEntry) -> Void) {
        let entry = ChallengeEntry(date: Date(), currentDay: 42, streakCount: 10)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ChallengeEntry>) -> Void) {
        // Static data for demo; real app should read from AppGroup shared data
        let entry = ChallengeEntry(date: Date(), currentDay: 42, streakCount: 10)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct ChallengeWidgetView: View {
    var entry: ChallengeProvider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text("75 Soft")
                .font(.headline)
            ProgressView(value: Double(entry.currentDay), total: 75.0)
            Text("Day \(entry.currentDay)\nStreak: \(entry.streakCount)")
                .font(.caption)
        }
        .padding()
        .containerBackground(.background, for: .widget)
    }
}


struct ChallengeWidget: Widget {
    let kind: String = "ChallengeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ChallengeProvider()) { entry in
            ChallengeWidgetView(entry: entry)
        }
        .configurationDisplayName("75 Soft Challenge")
        .description("Track your daily progress and streak.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct Soft75WidgetBundle: WidgetBundle {
    var body: some Widget {
        ChallengeWidget()
    }
}
