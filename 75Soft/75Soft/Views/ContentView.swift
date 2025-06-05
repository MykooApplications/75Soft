import SwiftUI
import SwiftData
import WidgetKit

enum SidebarDestination: Hashable {
    case settings, history
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [DailyEntry]
    @Query private var state: [ChallengeState]
    
    @State private var showResetConfirmation = false
    @State private var viewModel: ChallengeViewModel?
    @State private var showSidebar = false
    @State private var showAboutAlert = false
    @State private var navPath: [SidebarDestination] = []
    
    private var todayEntry: DailyEntry? {
        entries.first(where: { Calendar.current.isDateInToday($0.date) })
    }
    
    var body: some View {
        NavigationStack(path: $navPath) {
            ZStack(alignment: .leading) {
                mainContent
                    .disabled(showSidebar)
                    .blur(radius: showSidebar ? 4 : 0)
                
                if showSidebar {
                    // Background that detects taps outside the sidebar
                    Color.black.opacity(0.001) // Invisible but tappable
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showSidebar = false
                            }
                        }
                    
                    // Sidebar menu view
                    SidebarMenuView(
                        startDate: viewModel?.state.startDate ?? Date(),
                        currentDay: viewModel?.state.currentDay ?? 0,
                        resetCount: viewModel?.state.resetCount ?? 0,
                        showSidebar: $showSidebar,
                        showAboutAlert: $showAboutAlert,
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
                    if let vm = viewModel {
                        SettingsView(viewModel: vm)
                    }
                case .history:
                    HistoryView()
                }
            }
            .alert("About 75 Soft", isPresented: $showAboutAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("75 Soft is a 75-day challenge focusing on daily habits like hydration, exercise, and discipline. Complete all tasks daily to maintain your streak!")
            }
        }
    }
    
    private var mainContent: some View {
        VStack {
            Spacer()
            
            if let vm = viewModel {
                CircularProgressView(currentDay: vm.state.currentDay)
                Spacer()
                ChecklistView(viewModel: vm)
            } else {
                Button("Start Today") {
                    startToday()
                }
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            ensureChallengeState()
            if let entry = todayEntry, let challenge = state.first {
                viewModel = ChallengeViewModel(entry: entry, state: challenge, context: modelContext)
            }
        }
        .navigationTitle(showSidebar ? "" : "YOU CAN DO IT!")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(showSidebar ? .hidden : .visible)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    withAnimation { showSidebar.toggle() }
                }) {
                    Image(systemName: "line.3.horizontal")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Reset") {
                    showResetConfirmation = true
                }
            }
        }
        .alert("Reset Challenge?", isPresented: $showResetConfirmation) {
            Button("Reset", role: .destructive) {
                viewModel?.resetChallenge()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will erase today's progress and reset your streak. Are you sure?")
        }
    }
    
    private func startToday() {
        let newEntry = DailyEntry(date: Date())
        modelContext.insert(newEntry)
    }
    
    private func ensureChallengeState() {
        if state.isEmpty {
            let newState = ChallengeState(startDate: Date())
            modelContext.insert(newState)
        }
    }
    
    private func handleSidebarSelection(_ destination: SidebarDestination) {
        withAnimation { showSidebar = false }
        
        if destination == .settings || destination == .history {
            navPath.append(destination)
        } else {
            showAboutAlert = true
        }
    }
}
