// ContentView.swift

import SwiftUI
import SwiftData
import WidgetKit

enum SidebarDestination: Hashable {
    case settings, history, about
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    // 1. Fetch and sort your entries & state
    @Query(sort: \DailyEntry.date)
    private var entries: [DailyEntry]
    
    @Query(sort: \ChallengeState.startDate)
    private var challengeStates: [ChallengeState]
    
    // 2. View model + UI state
    @State private var viewModel: ChallengeViewModel?
    @State private var showSidebar = false
    @State private var showAboutAlert = false
    @State private var showResetConfirmation = false
    @State private var navPath: [SidebarDestination] = []
    
    // Helper to find today's entry
    private var todayEntry: DailyEntry? {
        entries.first { Calendar.current.isDateInToday($0.date) }
    }
    
    var body: some View {
        NavigationStack(path: $navPath) {
            ZStack(alignment: .leading) {
                mainContent
                    .disabled(showSidebar)
                    .blur(radius: showSidebar ? 4 : 0)

                if showSidebar {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture { toggleSidebar() }

                    SidebarMenuView(
                        startDate: viewModel?.state.startDate ?? Date(),
                        currentDay: viewModel?.state.currentDay ?? 0,
                        resetCount: viewModel?.state.resetCount ?? 0,
                        showSidebar: $showSidebar,
                        onSelect: handleSidebarSelection
                    )
                    .frame(width: 280)
                    .transition(.move(edge: .leading))
                    .zIndex(1)
                }
            }
            .navigationDestination(for: SidebarDestination.self) { destination in
                switch destination {
                case .settings:
                    SettingsView(viewModel: viewModel!)
                case .history:
                    HistoryView()
                case .about:
                    AboutView()
                }
            }
            .navigationTitle(showSidebar ? "" : "YOU CAN DO IT!")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: toggleSidebar) {
                        Image(systemName: "line.3.horizontal")
                    }
                    .opacity(showSidebar ? 0 : 1)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        showResetConfirmation = true
                    }
                    .opacity(showSidebar ? 0 : 1)
                }
            }
            .alert("About 75Soft", isPresented: $showAboutAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("75 Soft is a 75-day challenge focusing on daily habits like hydration, exercise, and discipline. Complete all tasks daily to maintain your streak!")
            }
        }
        .onAppear(perform: setupViewModel)
    }
    
    // MARK: - Main content
    private var mainContent: some View {
        VStack {
            Spacer()
            
            if let vm = viewModel {
                CircularProgressView(currentDay: vm.state.currentDay)
                    .frame(width: 300, height: 300)
                Spacer()
                ChecklistView(viewModel: vm)
            } else {
                Button("Start Today", action: startToday)
                    .buttonStyle(.borderedProminent)
            }
            
            Spacer()
        }
        .padding()
        .alert("Reset Challenge?", isPresented: $showResetConfirmation) {
            Button("Reset", role: .destructive) {
                viewModel?.resetChallenge()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will erase today's progress and reset your streak. Are you sure?")
        }
    }
    
    // MARK: - Setup
    private func setupViewModel() {
        // Ensure we always have one ChallengeState
        if challengeStates.isEmpty {
            let newState = ChallengeState(startDate: Date())
            modelContext.insert(newState)
            try? modelContext.save()
        }
        
        // If we haven’t yet created a VM, and we have both state + today’s entry, do so
        guard viewModel == nil,
              let challenge = challengeStates.first,
              let entry = todayEntry
        else { return }
        
        viewModel = ChallengeViewModel(
            entry: entry,
            state: challenge,
            context: modelContext
        )
    }
    
    private func startToday() {
        let newEntry = DailyEntry(date: Date())
        modelContext.insert(newEntry)
        try? modelContext.save()
        if let challenge = challengeStates.first {
            viewModel = ChallengeViewModel(
                entry: newEntry,
                state: challenge,
                context: modelContext
            )
        }
    }
    
    // MARK: - Sidebar helpers
    private func toggleSidebar() {
        withAnimation { showSidebar.toggle() }
    }
    
    private func handleSidebarSelection(_ destination: SidebarDestination) {
        toggleSidebar()
        navPath.append(destination)
    }
}
