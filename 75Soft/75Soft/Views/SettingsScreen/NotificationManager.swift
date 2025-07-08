//
//  NotificationManager.swift
//  75Soft
//
//  Created by Roshan Mykoo on 7/7/25.
//

import Foundation
import UserNotifications

/// This class is like a “to-do list” for reminders — it asks permission,
/// sets up daily reminders, milestone alerts, and can clear them out.
final class NotificationManager {
    /// We use a shared instance so the whole app talks to the same manager.
    static let shared = NotificationManager()
    /// This is the system’s notification center where reminders live.
    private let center = UNUserNotificationCenter.current()
    
    /// Make the init private so nobody else can create another manager.
    private init() { }
    
    /// Ask the user nicely if we can send notifications (alerts, sounds, badges).
    /// Calls the `completion` closure with `true` if they said yes, `false` otherwise.
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            // Switch back to the main thread before calling UI code
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    /// Schedule a reminder every day at the given hour and minute.
    /// For example: hour = 9, minute = 0 → every day at 9:00 AM.
    func scheduleDailyReminder(hour: Int, minute: Int) {
        // Remove any old daily reminder so we don't stack duplicates
        cancelDailyReminder()
        
        // 1️⃣ Create the message content
        let content = UNMutableNotificationContent()
        content.title = "75Soft: Daily Check-In"
        content.body  = "Don't forget to complete your 75Soft tasks for today!"
        content.sound = .default
        
        // 2️⃣ Define when it should fire
        var dateComponents = DateComponents()
        dateComponents.hour   = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true // repeat every day
        )
        
        // 3️⃣ Wrap it in a request with a unique ID
        let request = UNNotificationRequest(
            identifier: "dailyReminder",
            content: content,
            trigger: trigger
        )
        
        // 4️⃣ Add it to the notification center
        center.add(request) { error in
            if let error = error {
                print("❌ Error scheduling daily reminder: \(error)")
            }
        }
    }
    
    /// Cancel the daily reminder so it stops firing.
    func cancelDailyReminder() {
        center.removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
    }
    
    /// Schedule a one‐time “you hit a milestone!” notification right away.
    /// For example, milestone day = 7 → “You’ve reached a 7-day streak!”
    func scheduleMilestoneNotification(onDay day: Int) {
        let identifier = "milestoneReminder_\(day)"
        // Clear any previous same‐day reminder
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        
        // 1️⃣ Build the congratulations message
        let content = UNMutableNotificationContent()
        content.title = "Congratulations!"
        content.body  = "You've reached a \(day)-day streak! Keep it up!"
        content.sound = .default
        
        // 2️⃣ Fire it once after 1 second
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        // 3️⃣ Schedule it
        center.add(request) { error in
            if let error = error {
                print("❌ Error scheduling milestone reminder: \(error)")
            }
        }
    }
    
    /// Cancel all the milestone notifications that are still waiting.
    func cancelMilestoneNotifications() {
        center.getPendingNotificationRequests { requests in
            // Find all reminder IDs that start with "milestoneReminder_"
            let milestoneIDs = requests
                .map { $0.identifier }
                .filter { $0.starts(with: "milestoneReminder_") }
            // Remove them
            self.center.removePendingNotificationRequests(withIdentifiers: milestoneIDs)
        }
    }
}
