//
//  WidgetDataWriter.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/4/25.
//

import Foundation

func writeWidgetData(currentDay: Int, streak: Int, tasks: [String: Bool]) {
    let data = SharedWidgetData(currentDay: currentDay, streakCount: streak, tasks: tasks)
    print("✅ Writing widget data:")
    print("- Day: \(currentDay)")
    print("- Streak: \(streak)")
    print("- Tasks: \(tasks)")

    let encoder = JSONEncoder()
    guard let encoded = try? encoder.encode(data),
          let url = FileManager.default
              .containerURL(forSecurityApplicationGroupIdentifier: "group.com.roshanm.soft75")?
              .appendingPathComponent("widgetData.json")
    else {
        print("❌ Failed to encode or resolve App Group URL")
        return
    }

    do {
        try encoded.write(to: url)
        print("✅ Widget data saved to \(url)")
    } catch {
        print("❌ Failed writing widget data: \(error)")
    }
}
