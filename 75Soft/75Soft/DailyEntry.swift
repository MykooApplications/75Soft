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
class ChallengeState {
    var startDate: Date
    var currentDay: Int
    var streakCount: Int
    var lastCompletedDate: Date?

    init(startDate: Date) {
        self.startDate = startDate
        self.currentDay = 1
        self.streakCount = 0
        self.lastCompletedDate = nil
    }
}

