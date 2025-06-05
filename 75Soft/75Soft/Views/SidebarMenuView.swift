//
//  SidebarMenuView.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/5/25.
//
import SwiftUI

struct SidebarMenuView: View {
    let startDate: Date
    let currentDay: Int
    let resetCount: Int
    @Binding var showSidebar: Bool
    @Binding var showAboutAlert: Bool
    let onSelect: (SidebarDestination) -> Void

    var projectedEndDate: Date {
        Calendar.current.date(byAdding: .day, value: 74, to: startDate) ?? startDate
    }

    var completionPercentage: Int {
        min(Int((Double(currentDay) / 75.0) * 100), 100)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("75Soft")
                .font(.largeTitle)
                .bold()
                .padding(.top, 40)

            Section(header: Text("CHALLENGE OVERVIEW").font(.caption).foregroundColor(.gray)) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Start Date: \(formatted(startDate))")
                    Text("End Date: \(formatted(projectedEndDate))")
                    Text("Days Completed: \(currentDay)/75")
                    Text("Resets: \(resetCount)")
                    Text("Completion: \(completionPercentage)%")
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
            }

            Divider()

            Button(action: {
                onSelect(.history)
            }) {
                Label("History", systemImage: "calendar")
            }

            Button(action: {
                onSelect(.settings)
            }) {
                Label("Settings", systemImage: "gear")
            }

            Button(action: {
                withAnimation { showSidebar = false }
                showAboutAlert = true
            }) {
                Label("About", systemImage: "info.circle")
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: 280, maxHeight: .infinity)
        .background(Color(UIColor.systemGray6))
        .edgesIgnoringSafeArea(.all)
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
