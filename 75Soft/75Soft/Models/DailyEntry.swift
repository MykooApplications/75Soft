//
//  Untitled.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/4/25.
//

import Foundation
import SwiftData

@Model
class DailyEntry {
    @Attribute(.unique) var date: Date
    var waterCompleted: Bool = false
    var pagesRead: Bool = false
    var dietClean: Bool = false
    var workoutDone: Bool = false

    init(date: Date) {
        self.date = date
    }
}

@Model
final class ChallengeState {
    var startDate: Date
    var currentDay: Int
    var streakCount: Int
    var lastCompletedDate: Date?
    var resetCount: Int
    
    var forgiveMissedDay: Bool = false
    var forgiveMissedTask: Bool = false

    init(startDate: Date) {
        self.startDate = startDate
        self.currentDay = 0          // was 1, now 0
        self.streakCount = 0
        self.lastCompletedDate = nil
        self.resetCount = 0
    }
}
