//
//  WidgetDataWriter.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/4/25.
//

import Foundation

// This function packages up your challenge progress and saves it so your home screen widget can show the latest info.
// - Parameters:
//   - currentDay: The number of days you've completed so far (like “Day 5”).
//   - streak: How many days in a row you’ve kept your streak alive.
//   - tasks: A dictionary of each task’s name and whether you’ve done it today (true = done, false = not yet).
func writeWidgetData(currentDay: Int, streak: Int, tasks: [String: Bool]) {
    // 1) Wrap up all the info in a SharedWidgetData object
    let data = SharedWidgetData(
        currentDay: currentDay,
        streakCount: streak,
        tasks: tasks
    )
    
    // 2) Print it out in the console so we know what we're about to save
    print("✅ Writing widget data:")
    print("- Day: \(currentDay)")
    print("- Streak: \(streak)")
    print("- Tasks: \(tasks)")
    
    // 3) Convert our SharedWidgetData into JSON bytes
    let encoder = JSONEncoder()
    //    • encoded = the JSON data
    //    • url     = the special folder shared between app and widget
    guard let encoded = try? encoder.encode(data),
          let url = FileManager.default
        .containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.roshanm.soft75"
        )?
        .appendingPathComponent("widgetData.json")
    else {
        // If something went wrong (couldn't make JSON or find the folder), we bail out
        print("❌ Failed to encode or resolve App Group URL")
        return
    }
    
    // 4) Try to write the JSON data into our shared file
    do {
        try encoded.write(to: url)
        // Success! Now the widget can pick up the latest numbers.
        print("✅ Widget data saved to \(url)")
    } catch {
        // If the file write fails, tell us why
        print("❌ Failed writing widget data: \(error)")
    }
}
