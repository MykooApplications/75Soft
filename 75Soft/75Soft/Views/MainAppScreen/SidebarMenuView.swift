import SwiftUI

struct SidebarMenuView: View {
    let startDate: Date
    let currentDay: Int
    let resetCount: Int
    @Binding var showSidebar: Bool
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

            Section(header: Text("CHALLENGE OVERVIEW")
                        .font(.caption)
                        .foregroundColor(.gray)) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Start Date: \(formatted(startDate))")
                    Text("End Date: \(formatted(projectedEndDate))")
                    Text("Days Completed: \(currentDay)/75")
                    Text("Resets: \(resetCount)")
                    Text("Completion: \(completionPercentage)%")
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
            }

            Divider()

            Button {
                withAnimation { showSidebar = false }
                onSelect(.history)
            } label: {
                Label("History", systemImage: "calendar")
            }

            Button {
                withAnimation { showSidebar = false }
                onSelect(.settings)
            } label: {
                Label("Settings", systemImage: "gear")
            }

            Button {
                withAnimation { showSidebar = false }
                onSelect(.about)
            } label: {
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
