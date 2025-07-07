//
//  SettingsView 2.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/5/25.
//
import SwiftUI
import WidgetKit
import SwiftData


struct SettingsView: View {
    @ObservedObject var viewModel: ChallengeViewModel

    // MARK: - AppStorage Keys
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled: Bool = false
    @AppStorage("milestoneReminderEnabled") private var milestoneReminderEnabled: Bool = false
    @AppStorage("dailyReminderTime") private var dailyReminderTime: Date = Date()
    @AppStorage("showDeveloperOptions") private var showDeveloperOptions: Bool = false

    // MARK: - Alert State
    @State private var showResetAlert = false
    @State private var showClearAlert = false
    @State private var showOnboarding = false
    @State private var showLogicInfo = false

    var body: some View {
        Form {
            // 1. Profile & Challenge Info
            Section(header: Text("Profile & Challenge Info")) {
                HStack {
                    Text("Start Date")
                    Spacer()
                    Text(viewModel.state.startDate, style: .date)
                }
                HStack {
                    Text("Projected End Date")
                    Spacer()
                    Text(viewModel.state.startDate.addingTimeInterval(74 * 24 * 60 * 60), style: .date)
                }
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

            // 2. Notifications
            Section(header: Text("Notifications")) {
                Toggle("Daily Reminders", isOn: $dailyReminderEnabled)
                    .onChange(of: dailyReminderEnabled) { newValue in
                        NotificationManager.shared.requestAuthorization { granted in
                            guard granted else {
                                dailyReminderEnabled = false
                                return
                            }
                            if newValue {
                                let components = Calendar.current.dateComponents([.hour, .minute], from: dailyReminderTime)
                                NotificationManager.shared.scheduleDailyReminder(
                                    hour: components.hour!,
                                    minute: components.minute!
                                )
                            } else {
                                NotificationManager.shared.cancelDailyReminder()
                            }
                        }
                    }

                if dailyReminderEnabled {
                    DatePicker(
                        "Reminder Time",
                        selection: $dailyReminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .onChange(of: dailyReminderTime) { newTime in
                        let comps = Calendar.current.dateComponents([.hour, .minute], from: newTime)
                        NotificationManager.shared.scheduleDailyReminder(hour: comps.hour!, minute: comps.minute!)
                    }
                }
               // Toggle("Milestone/Streak Notifications", isOn: $milestoneReminderEnabled)
            }

            // 3. Reset Options
            Section(header: Text("Reset Options")) {
                Button(role: .destructive) {
                    showResetAlert = true
                } label: {
                    Label("Reset Challenge", systemImage: "gobackward")
                }
                Button(role: .destructive) {
                    showClearAlert = true
                } label: {
                    Label("Clear All Data", systemImage: "trash")
                }
                .alert("Clear All Data?", isPresented: $showClearAlert) {
                    Button("Clear", role: .destructive) {
                        // TODO: implement data clearing
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This will remove all stored data and cannot be undone.")
                }
            }

            // 4. Learn About 75Soft
            Section(header: Text("Learn About 75Soft")) {
                NavigationLink("Show Onboarding", isActive: $showOnboarding) {
                    OnboardingView(hasCompletedOnboarding: $showOnboarding)
                }
                Button("Streak Logic Explanation") {
                    showLogicInfo = true
                }
                .sheet(isPresented: $showLogicInfo) {
                    VStack(spacing: 16) {
                        Text("How Streak Works")
                            .font(.headline)
                        Text("Your streak only increments when all tasks are completed in a single day. Missing any task resets your streak to zero unless you log that you forgot to record.")
                            .padding()
                        Spacer()
                        Button("Done") { showLogicInfo = false }
                    }
                    .padding()
                }
            }

            // 5. Advanced / Developer Options
            #if DEBUG
            Section(header: Text("Developer Options")) {
                            Toggle("Show Developer Options", isOn: $showDeveloperOptions)
                            if showDeveloperOptions {
                                HStack {
                                    Text("App Version")
                                    Spacer()
                                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?")
                                }
                                HStack {
                                    Text("Build Number")
                                    Spacer()
                                    Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?")
                                }
                                Button("Test Daily Reminder Now") {
                                    let comps = Calendar.current.dateComponents([.hour, .minute], from: dailyReminderTime)
                                    NotificationManager.shared.scheduleDailyReminder(
                                        hour: comps.hour ?? 9,
                                        minute: comps.minute ?? 0
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
                                    // TODO: implement export
                                }
                            }
                        }
#endif

            // 6. Footer
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
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
// Preview
struct SettingsView_Previews: PreviewProvider {
    static var container: ModelContainer = {
        do {
            let config = ModelConfiguration()
            return try ModelContainer(
                for: DailyEntry.self,
                     ChallengeState.self,
                configurations: config
            )
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
