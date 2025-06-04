//
//  ContentView.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/4/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [DailyEntry]
    @Query private var state: [ChallengeState]
    
    private var todayEntry: DailyEntry? {
        entries.first(where: { Calendar.current.isDateInToday($0.date) })
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top 2/3 — Circular progress
                VStack {
                    if let state = state.first {
                        Spacer()
                        CircularProgressView(currentDay: state.currentDay)
                        Spacer()
                    }
                }
                .frame(height: geometry.size.height * 0.66)
                // Bottom 1/3 — Checklist
                VStack {
                    GeometryReader { proxy in
                        VStack {
                            Spacer()
                            Group {
                                if let entry = todayEntry, let challenge = state.first {
                                    ChecklistView(viewModel: <#ChallengeViewModel#>)
                                } else {
                                    Button("Start Today") {
                                        addTodayEntry()
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            Spacer()
                        }
                        .frame(height: proxy.size.height)
                    }
                }
                .frame(height: geometry.size.height * 0.34)
            }
            .padding()
        }
        .onAppear(perform: checkChallengeState)
        .onAppear(
            
        )
    }
    
    private func addTodayEntry() {
        let newEntry = DailyEntry(date: Date())
        modelContext.insert(newEntry)
    }
    
    private func checkChallengeState() {
        guard let challenge = state.first else {
            let newState = ChallengeState(startDate: Date())
            modelContext.insert(newState)
            return
        }
        
        if let lastDate = challenge.lastCompletedDate,
           !Calendar.current.isDateInToday(lastDate),
           !Calendar.current.isDateInYesterday(lastDate) {
            // Missed a day
            DispatchQueue.main.async {
                showResetPrompt(for: challenge)
            }
        }
    }
    
    private func showResetPrompt(for challenge: ChallengeState) {
        // Use your custom UI or alert system to prompt
        // Here is a placeholder log statement
        print("Prompt user: Did you forget to log yesterday?")
        // If they confirm they missed a day:
        challenge.currentDay = 1
        challenge.streakCount = 0
        challenge.startDate = Date()
        challenge.lastCompletedDate = nil
    }
}

