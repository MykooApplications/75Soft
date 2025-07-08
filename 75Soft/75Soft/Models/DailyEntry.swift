//
//  DailyEntry.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/4/25.
//

import Foundation
import SwiftData

// This class keeps track of what you did on a single day.
// Think of it as your daily checklist: did you drink water? read pages? eat clean? work out?
@Model
class DailyEntry {
    // The date for this entry – like "June 10, 2025"
    @Attribute(.unique) var date: Date
    
    // These start as false (you haven't done them yet).
    // We'll flip them to true when you complete each task.
    var waterCompleted: Bool = false    // Did you drink your 3 liters of water?
    var pagesRead: Bool      = false    // Did you read 10 pages?
    var dietClean: Bool      = false    // Did you stick to your diet?
    var workoutDone: Bool    = false    // Did you finish your 45-minute workout?
    
    // When we create a DailyEntry, we give it the date it belongs to.
    init(date: Date) {
        self.date = date
    }
}

// This class remembers the big-picture info about your 75-day challenge.
// It tracks when you started, how many days you've gone in a row, and so on.
@Model
final class ChallengeState {
    var startDate: Date         // The very first day you started the challenge
    var currentDay: Int         // Which day number you're on right now (0 means "not started yet")
    var streakCount: Int        // How many days in a row you've completed
    var lastCompletedDate: Date?// The date of the last day you finished all tasks
    var resetCount: Int         // How many times you've had to start over
    
    // New "forgiveness" settings:
    // If forgiveMissedDay is true, missing one whole day won't reset your streak.
    var forgiveMissedDay: Bool = false
    // If forgiveMissedTask is true, skipping one task won't make you lose your streak.
    var forgiveMissedTask: Bool = false
    
    // When you start a brand-new ChallengeState, you tell it the day you began.
    // Everything else starts at zero or nil because you haven't done anything yet.
    init(startDate: Date) {
        self.startDate = startDate
        self.currentDay = 0       // We haven't started Day 1 until you finish your first full day
        self.streakCount = 0      // No streak until you've completed tasks
        self.lastCompletedDate = nil
        self.resetCount = 0       // You haven't reset the challenge yet
    }
}
