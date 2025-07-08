//
//  SidebarMenuView.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/4/25.
//

import SwiftUI

struct SidebarMenuView: View {
    // The date the challenge started
    let startDate: Date
    // How many days in a row the user has completed
    let currentDay: Int
    // How many times the user has reset the challenge
    let resetCount: Int
    // Binding to show or hide the sidebar
    @Binding var showSidebar: Bool
    // Binding to trigger the "About" alert
    @Binding var showAboutAlert: Bool
    // Called when the user taps a menu item like History or Settings
    let onSelect: (SidebarDestination) -> Void
    
    // Calculate the date 74 days after the start (that makes a 75-day span)
    var projectedEndDate: Date {
        Calendar.current.date(byAdding: .day, value: 74, to: startDate)!
    }
    
    // Convert how many days done into a percent (max 100%)
    var completionPercentage: Int {
        min(Int((Double(currentDay) / 75.0) * 100), 100)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title at the top
            Text("75Soft")
                .font(.largeTitle)
                .bold()
                .padding(.top, 40)  // push it down from the very top
            
            // Small gray header for the overview section
            Text("CHALLENGE OVERVIEW")
                .font(.caption)
                .foregroundColor(.gray)
            
            // Card showing key stats
            VStack(alignment: .leading, spacing: 4) {
                Text("Start Date: \(formatted(startDate))")
                Text("End Date:   \(formatted(projectedEndDate))")
                Text("Days Completed: \(currentDay)/75")
                Text("Resets:           \(resetCount)")
                Text("Completion:      \(completionPercentage)%")
            }
            .padding()  // space inside the card
            .frame(maxWidth: .infinity, alignment: .leading)  // stretch full width
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)  // round corners of the card
            
            Divider()  // little line separator
            
            // History button
            Button(action: { onSelect(.history) }) {
                Label("History", systemImage: "calendar")
            }
            // Settings button
            Button(action: { onSelect(.settings) }) {
                Label("Settings", systemImage: "gear")
            }
            // About button: first close sidebar, then show alert
            Button {
                withAnimation { showSidebar = false }
                showAboutAlert = true
            } label: {
                Label("About", systemImage: "info.circle")
            }
            
            Spacer()  // push everything up, leaving empty space below
        }
        .padding()  // overall padding inside the sidebar
        .frame(maxWidth: 280)  // fixed width for the sidebar
        .background(Color(UIColor.systemGray6))  // light gray background
        .edgesIgnoringSafeArea(.all)  // allow full-height background
    }
    
    // Helper to turn a Date into a friendly string
    private func formatted(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        return fmt.string(from: date)
    }
}
