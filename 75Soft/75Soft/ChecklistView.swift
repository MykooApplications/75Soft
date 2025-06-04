//
//  ChecklistView.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/4/25.
//

import SwiftUI
import SwiftData
import WidgetKit

struct ChecklistView: View {
    @Bindable var entry: DailyEntry
    var challengeState: ChallengeState
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack(spacing: 16) {
            checklistRow("Drank 3L of Water", isCompleted: $entry.waterCompleted)
            checklistRow("Read 10 Pages of a book", isCompleted: $entry.pagesRead)
            checklistRow("Stuck to my diet", isCompleted: $entry.dietClean)
            checklistRow("Completed 45 Min Workout", isCompleted: $entry.workoutDone)
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, 40)
    }
    
    @ViewBuilder
    func checklistRow(_ title: String, isCompleted: Binding<Bool>) -> some View {
        HStack {
            Button(action: {
                isCompleted.wrappedValue.toggle()
                checkCompletion()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }) {
                ZStack {
                    Circle()
                        .strokeBorder(isCompleted.wrappedValue ? Color.accentColor : Color.gray, lineWidth: 2)
                        .frame(width: 28, height: 28)
                    if isCompleted.wrappedValue {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 18, height: 18)
                    }
                }
            }
            .buttonStyle(.plain)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
                .padding(.leading, 8)
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    
    private func checkCompletion() {
        if entry.waterCompleted && entry.pagesRead && entry.dietClean && entry.workoutDone {
            let lastDate = challengeState.lastCompletedDate

            if lastDate == nil || !Calendar.current.isDateInToday(lastDate!) {
                challengeState.streakCount += 1
                challengeState.currentDay += 1
                challengeState.lastCompletedDate = Date()

                // ✅ Save to widget
                writeWidgetData(
                    currentDay: challengeState.currentDay,
                    streak: challengeState.streakCount,
                    tasks: [
                        "💧 Water": entry.waterCompleted,
                        "📖 Read": entry.pagesRead,
                        "🥗 Diet": entry.dietClean,
                        "🏃‍♂️ Workout": entry.workoutDone
                    ]
                )

                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
}
