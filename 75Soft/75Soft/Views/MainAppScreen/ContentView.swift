//
//  ContentView.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/4/25.
//
import SwiftUI
import SwiftData
import WidgetKit

enum SidebarDestination: Hashable {
    case settings, history, about
}

struct ContentView: View {
    // We need ModelContext to read/write our SwiftData models
    @Environment(\.modelContext) private var modelContext
    
    // 1) Grab all past daily entries, sorted by date (oldest first)
    @Query(sort: \DailyEntry.date)
    private var entries: [DailyEntry]
    
    // 2) Grab our single ChallengeState (when you first launch, we’ll create one)
    @Query(sort: \ChallengeState.startDate)
    private var challengeStates: [ChallengeState]
    
    // These @State flags drive our side-menu, alerts, and navigation
    @State private var viewModel: ChallengeViewModel?
    @State private var showSidebar = false
    @State private var showAboutAlert = false
    @State private var showResetConfirmation = false
    @State private var navPath: [SidebarDestination] = []
    
    // Helper: “todayEntry” finds if we already made an entry for today
    private var todayEntry: DailyEntry? {
        entries.first { Calendar.current.isDateInToday($0.date) }
    }
    
    var body: some View {
        // NavigationStack lets us push new screens via `navPath`
        NavigationStack(path: $navPath) {
            ZStack(alignment: .leading) {
                // Put our main screen content here
                mainContent
                    .disabled(showSidebar)         // disable taps when sidebar is open
                    .blur(radius: showSidebar ? 4 : 0)  // blur the background
                
                // Show the sidebar if requested
                if showSidebar {
                    // 1) A transparent overlay that catches taps to close the menu
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture { toggleSidebar() }
                    
                    // 2) The sliding menu itself
                    SidebarMenuView(
                        startDate: viewModel?.state.startDate ?? Date(),
                        currentDay: viewModel?.state.currentDay ?? 0,
                        resetCount: viewModel?.state.resetCount ?? 0,
                        showSidebar: $showSidebar,
                        showAboutAlert: $showAboutAlert,
                        onSelect: handleSidebarSelection
                    )
                    .frame(width: 280)             // fixed width for the menu
                    .transition(.move(edge: .leading))
                    .zIndex(1)                     // sit on top of everything else
                }
            }
            // 3) Add swipe gestures (left/right) to open/close sidebar
            .highPriorityGesture(
                DragGesture(minimumDistance: 20)
                    .onEnded { value in
                        let threshold: CGFloat = 80
                        if value.translation.width > threshold {
                            withAnimation { showSidebar = true }
                        } else if value.translation.width < -threshold {
                            withAnimation { showSidebar = false }
                        }
                    },
                including: .all
            )
            // 4) Handle navigation destinations (Settings, History, About)
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
            // 5) Title and toolbar button (hamburger menu)
            .navigationTitle(showSidebar ? "" : "YOU CAN DO IT!")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: toggleSidebar) {
                        Image(systemName: "line.3.horizontal")
                    }
                    .opacity(showSidebar ? 0 : 1)  // hide button when menu is open
                }
            }
            // 6) The About alert (popup)
            .alert("About 75Soft", isPresented: $showAboutAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(
                    "75 Soft is a 75-day challenge focusing on daily habits like hydration, exercise, and discipline. Complete all tasks daily to maintain your streak!"
                )
            }
        }
        .onAppear(perform: setupViewModel)  // When screen appears, make sure VM exists
    }
    
    // MARK: – Main content area
    private var mainContent: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 40)  // give space under the nav bar
            
            if let vm = viewModel {
                // — Center the big circle progress —
                HStack {
                    Spacer()
                    CircularProgressView(currentDay: vm.state.currentDay)
                        .frame(width: 300, height: 300)
                    Spacer()
                }
                .padding(.bottom, 24)
                
                Spacer()
                
                // — Center the checklist —
                HStack {
                    Spacer()
                    ChecklistView(viewModel: vm)
                        .frame(maxWidth: 360)  // don’t get too wide
                    Spacer()
                }
                .padding(.bottom, 40)
            } else {
                // If we haven’t started today yet, show a “Start Today” button
                Button("Start Today", action: startToday)
                    .buttonStyle(.borderedProminent)
                    .font(.title2)
            }
            
            Spacer()  // push content up
        }
        .padding(.horizontal)  // side padding so things don’t touch screen edges
    }
    
    // MARK: – One-time setup for our ViewModel
    private func setupViewModel() {
        // If no ChallengeState exists, create one now
        if challengeStates.isEmpty {
            let newState = ChallengeState(startDate: Date())
            modelContext.insert(newState)
            try? modelContext.save()
        }
        
        // If VM is nil and we have both today’s entry & a challenge state, build it
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
    
    // MARK: – Start today by inserting a new DailyEntry
    private func startToday() {
        let newEntry = DailyEntry(date: Date())
        modelContext.insert(newEntry)
        try? modelContext.save()
        
        // Immediately create VM so UI updates
        if let challenge = challengeStates.first {
            viewModel = ChallengeViewModel(
                entry: newEntry,
                state: challenge,
                context: modelContext
            )
        }
    }
    
    // MARK: – Sidebar open/close helpers
    private func toggleSidebar() {
        withAnimation { showSidebar.toggle() }
    }
    
    private func handleSidebarSelection(_ destination: SidebarDestination) {
        toggleSidebar()            // close the menu
        navPath.append(destination) // navigate to chosen screen
    }
}
