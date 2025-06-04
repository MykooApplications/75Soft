//
//  SharedWidgetData.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/4/25.
//
import Foundation

struct SharedWidgetData: Codable {
    let currentDay: Int
    let streakCount: Int
    let tasks: [String: Bool]
}
