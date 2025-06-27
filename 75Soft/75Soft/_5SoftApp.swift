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
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
        // ← Inject your SwiftData model here:
        .modelContainer(
            for: [
                DailyEntry.self,
                ChallengeState.self
            ]
        )
    }
}
