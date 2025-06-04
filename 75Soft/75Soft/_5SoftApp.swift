//
//  _5SoftApp.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/4/25.
//

import SwiftUI
import SwiftData

@main
struct Soft75App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [DailyEntry.self, ChallengeState.self])
        }
    }
}
