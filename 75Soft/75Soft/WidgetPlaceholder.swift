//
//  WidgetPlaceholder.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/4/25.
//

import WidgetKit
import SwiftUI

struct Placeholder75SoftWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Placeholder75SoftWidget", provider: Provider()) { entry in
            Text("75 Soft Tracker")
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName("75 Soft Progress")
        .description("Track your daily challenge tasks.")
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(SimpleEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let entries = [SimpleEntry(date: Date())]
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}
