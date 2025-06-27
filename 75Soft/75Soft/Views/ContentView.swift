// ContentView.swift
import SwiftUI
import SwiftData
import WidgetKit

enum SidebarDestination: Hashable {
    case settings, history, about
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [DailyEntry]
    @Query private var state: [ChallengeState]

    @State private var showResetConfirmation = false
    @State private var viewModel: ChallengeViewModel?
    @State private var showSidebar = false
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
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture { withAnimation { showSidebar = false } }

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
                    if let vm = viewModel {
                        SettingsView(viewModel: vm)
                    }
                case .history:
                    HistoryView()
                case .about:
                    AboutView()
                }
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
                .buttonStyle(.borderedProminent)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            ensureChallengeState()
            if viewModel == nil,
               let entry = todayEntry,
               let challenge = state.first {
                viewModel = ChallengeViewModel(entry: entry, state: challenge, context: modelContext)
            }
        }
        .navigationTitle(showSidebar ? "" : "YOU CAN DO IT!")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    withAnimation { showSidebar.toggle() }
                } label: {
                    Image(systemName: "line.3.horizontal")
                }
            }
            if viewModel != nil {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") { showResetConfirmation = true }
                }
            }
        }
        .alert("Reset Challenge?", isPresented: $showResetConfirmation) {
            Button("Reset", role: .destructive) { viewModel?.resetChallenge() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will erase today's progress and reset your streak. Are you sure?")
        }
    }

    private func startToday() {
        let newEntry = DailyEntry(date: Date())
        modelContext.insert(newEntry)
        try? modelContext.save()
        if let challenge = state.first {
            viewModel = ChallengeViewModel(entry: newEntry, state: challenge, context: modelContext)
        }
    }

    private func ensureChallengeState() {
        if state.isEmpty {
            let newState = ChallengeState(startDate: Date())
            modelContext.insert(newState)
            try? modelContext.save()
        }
    }

    private func handleSidebarSelection(_ destination: SidebarDestination) {
        withAnimation { showSidebar = false }
        navPath.append(destination)
    }
}
