//
//  NotificationManager.swift
//  75Soft
//
//  Created by Roshan Mykoo on 7/7/25.
//

import Foundation
import UserNotifications

/// Centralized manager for scheduling and managing local notifications
final class NotificationManager {
    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()

    private init() { }

    /// Request permission from the user
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    /// Schedule a repeating daily reminder at the given hour/minute
    func scheduleDailyReminder(hour: Int, minute: Int) {
        // First, remove any existing daily reminder
        cancelDailyReminder()

        let content = UNMutableNotificationContent()
        content.title = "75Soft: Daily Check-In"
        content.body = "Don't forget to complete your 75Soft tasks for today!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "dailyReminder",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("❌ Error scheduling daily reminder: \(error)")
            }
        }
    }

    /// Cancel any scheduled daily reminder
    func cancelDailyReminder() {
        center.removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
    }

    /// Schedule a milestone notification when user hits a streak milestone
    func scheduleMilestoneNotification(onDay day: Int) {
        let identifier = "milestoneReminder_\(day)"
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = "Congratulations!"
        content.body = "You've reached a \(day)-day streak! Keep it up!"
        content.sound = .default

        // Fire immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("❌ Error scheduling milestone reminder: \(error)")
            }
        }
    }

    /// Cancel all milestone notifications
    func cancelMilestoneNotifications() {
        center.getPendingNotificationRequests { requests in
            let milestoneIDs = requests
                .map { $0.identifier }
                .filter { $0.starts(with: "milestoneReminder_") }
            self.center.removePendingNotificationRequests(withIdentifiers: milestoneIDs)
        }
    }
}
