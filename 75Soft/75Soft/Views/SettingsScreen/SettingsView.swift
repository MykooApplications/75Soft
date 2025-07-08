//
//  SettingsView.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/5/25.
//
import SwiftUI
import WidgetKit
import SwiftData

/// This view shows your app settings, letting you tweak reminders,
/// reset the challenge, and peek under the hood if you’re a developer.
struct SettingsView: View {
    // We observe the same viewModel that drives the main challenge logic.
    @ObservedObject var viewModel: ChallengeViewModel
    
    // SwiftData context so we can save any changes to our models.
    @Environment(\.modelContext) private var modelContext: ModelContext
    
    // MARK: – Storage for toggles & times
    
    /// Remember if daily reminders are on/off
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled: Bool = false
    /// Remember if milestone notifications are on/off
    @AppStorage("milestoneReminderEnabled") private var milestoneReminderEnabled: Bool = false
    /// Remember what time the user chose for daily reminders
    @AppStorage("dailyReminderTime") private var dailyReminderTime: Date = Date()
    /// Show or hide extra developer options
    @AppStorage("showDeveloperOptions") private var showDeveloperOptions: Bool = false
    /// Forgive missing a full day (won’t reset streak)
    @AppStorage("forgiveMissDay") private var forgiveDayEnabled: Bool = false
    /// Forgive missing individual tasks
    @AppStorage("forgiveMissTask") private var forgiveTaskEnabled: Bool = false
    
    // Pull in our single ChallengeState (or make one if missing)
    @Query private var state: [ChallengeState]
    private var challenge: ChallengeState {
        if let existing = state.first {
            return existing
        } else {
            // No state yet → create it!
            let newOne = ChallengeState(startDate: Date())
            modelContext.insert(newOne)
            try? modelContext.save()
            return newOne
        }
    }
    
    // MARK: – Local view state for alerts & sheets
    
    @State private var showResetAlert   = false
    @State private var showClearAlert   = false
    @State private var showOnboarding   = false
    @State private var showLogicInfo    = false
    
    var body: some View {
        Form {
            // 1️⃣ Profile & Challenge Info
            Section(header: Text("Profile & Challenge Info")) {
                // Show the start date
                HStack {
                    Text("Start Date")
                    Spacer()
                    Text(viewModel.state.startDate, style: .date)
                }
                // Show the projected end date (74 days later)
                HStack {
                    Text("Projected End Date")
                    Spacer()
                    Text(
                        viewModel.state.startDate.addingTimeInterval(74 * 24 * 60 * 60),
                        style: .date
                    )
                }
                // Button to reset everything
                Button(role: .destructive) {
                    showResetAlert = true
                } label: {
                    Text("Reset Challenge")
                }
                .alert("Reset Challenge?", isPresented: $showResetAlert) {
                    Button("Reset", role: .destructive) {
                        viewModel.resetChallenge()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This will erase all progress and reset your streak to zero.")
                }
            }
            
            // 2️⃣ Notifications
            Section(header: Text("Notifications")) {
                // Toggle daily reminders on/off
                Toggle("Daily Reminders", isOn: $dailyReminderEnabled)
                    .onChange(of: dailyReminderEnabled) { newValue in
                        // Ask permission if turning on
                        NotificationManager.shared.requestAuthorization { granted in
                            guard granted else {
                                dailyReminderEnabled = false
                                return
                            }
                            if newValue {
                                // Schedule at the stored time
                                let comps = Calendar.current.dateComponents([.hour, .minute], from: dailyReminderTime)
                                NotificationManager.shared.scheduleDailyReminder(
                                    hour: comps.hour!, minute: comps.minute!
                                )
                            } else {
                                // Turn it off
                                NotificationManager.shared.cancelDailyReminder()
                            }
                        }
                    }
                
                // If reminders are on, show a time picker
                if dailyReminderEnabled {
                    DatePicker(
                        "Reminder Time",
                        selection: $dailyReminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .onChange(of: dailyReminderTime) { newTime in
                        let comps = Calendar.current.dateComponents([.hour, .minute], from: newTime)
                        NotificationManager.shared.scheduleDailyReminder(
                            hour: comps.hour!, minute: comps.minute!
                        )
                    }
                }
            }
            
            // 3️⃣ Difficulty Settings
            Section(header: Text("Difficulty")) {
                // Toggle forgiving a missed day
                Toggle("Forgive Missed Day",
                       isOn: Binding(
                        get: { challenge.forgiveMissedDay },
                        set: { newValue in
                            challenge.forgiveMissedDay = newValue
                            try? modelContext.save()
                        }
                       )
                )
                // Toggle forgiving missing a single task
                Toggle("Forgive Missed Task",
                       isOn: Binding(
                        get: { challenge.forgiveMissedTask },
                        set: { newValue in
                            challenge.forgiveMissedTask = newValue
                            try? modelContext.save()
                        }
                       )
                )
            }
            
            // 4️⃣ Reset Options
            Section(header: Text("Reset Options")) {
                // Another reset button for convenience
                Button(role: .destructive) {
                    showResetAlert = true
                } label: {
                    Label("Reset Challenge", systemImage: "gobackward")
                }
                // Button to clear all app data
                Button(role: .destructive) {
                    showClearAlert = true
                } label: {
                    Label("Clear All Data", systemImage: "trash")
                }
                .alert("Clear All Data?", isPresented: $showClearAlert) {
                    Button("Clear", role: .destructive) {
                        // TODO: wipe out local data
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This will remove all stored data and cannot be undone.")
                }
            }
            
            // 5️⃣ Learn About 75Soft
            Section(header: Text("Learn About 75Soft")) {
                // Show onboarding screens again
                NavigationLink("Show Onboarding", isActive: $showOnboarding) {
                    OnboardingView(hasCompletedOnboarding: $showOnboarding)
                }
                // Quick explanation in a sheet
                Button("Streak Logic Explanation") {
                    showLogicInfo = true
                }
                .sheet(isPresented: $showLogicInfo) {
                    VStack(spacing: 16) {
                        Text("How Streak Works")
                            .font(.headline)
                        Text("""
                             Your streak only increments when all tasks are completed in a single day.
                             Missing any task resets your streak to zero unless you marked it forgiven.
                             """)
                        .padding()
                        Spacer()
                        Button("Done") { showLogicInfo = false }
                    }
                    .padding()
                }
            }
            
            // 6️⃣ Developer Options (only in DEBUG builds)
#if DEBUG
            Section(header: Text("Developer Options")) {
                Toggle("Show Developer Options", isOn: $showDeveloperOptions)
                if showDeveloperOptions {
                    // Version info
                    HStack {
                        Text("App Version"); Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?")
                    }
                    HStack {
                        Text("Build Number"); Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?")
                    }
                    // Buttons to manually trigger features for testing
                    Button("Test Daily Reminder Now") {
                        let comps = Calendar.current.dateComponents([.hour, .minute], from: dailyReminderTime)
                        NotificationManager.shared.scheduleDailyReminder(
                            hour: comps.hour ?? 9, minute: comps.minute ?? 0
                        )
                    }
                    Button("Trigger Milestone (7-day)") {
                        NotificationManager.shared.scheduleMilestoneNotification(onDay: 7)
                    }
                    Button("Clear All Notifications") {
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    }
                    Button("Force Widget Refresh") {
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                    Button("Jump to Day 74 (Test Completed Challenge)") {
                        viewModel.jumpToDay(74)
                    }
                    Button("Export Logs") {
                        // TODO: implement log export
                    }
                }
            }
#endif
            
            // 7️⃣ Footer with a sweet note
            Section {
                HStack {
                    Spacer()
                    Text("Built with ❤️ by Roshan")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        // Title at top
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Preview snippet to see it in Xcode’s canvas
struct SettingsView_Previews: PreviewProvider {
    static var container: ModelContainer = {
        do {
            let config = ModelConfiguration()
            return try ModelContainer(for: DailyEntry.self, ChallengeState.self, configurations: config)
        } catch {
            fatalError("Failed to create in-memory model container: \(error)")
        }
    }()
    
    static var previews: some View {
        NavigationStack {
            SettingsView(
                viewModel: ChallengeViewModel(
                    entry: DailyEntry(date: Date()),
                    state: ChallengeState(startDate: Date()),
                    context: container.mainContext
                )
            )
        }
        .modelContainer(container)
    }
}
