//
//  WidgetDataWriter.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/4/25.
//

import Foundation

func writeWidgetData(currentDay: Int, streak: Int, tasks: [String: Bool]) {
    let data = SharedWidgetData(currentDay: currentDay, streakCount: streak, tasks: tasks)

    let encoder = JSONEncoder()
    
    guard let encoded = try? encoder.encode(data),
          let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.yourname.soft75")
    else {
        print("❌ Failed to encode data or get container URL")
        return
    }

    let fileURL = containerURL.appendingPathComponent("widgetData.json")
    
    do {
        try encoded.write(to: fileURL)
        print("✅ Widget data written")
    } catch {
        print("❌ Failed to write widget data: \(error)")
    }
}
