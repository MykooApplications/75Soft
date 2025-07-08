//
//  CalendarView.swift
//  75Soft
//
//  Created by Roshan Mykoo on 6/4/25.
//

import SwiftUI
import SwiftData
import WidgetKit

// MARK: – Day Status Enum
// This tells us what happened on a specific calendar day.
enum DayStatus {
    case completed  // You finished every task that day
    case missed     // You missed at least one task
    case future     // That day hasn’t happened yet
    case reset      // You reset your challenge on that day
    case none       // No data available for that day
}

// MARK: – Single-Day Model
// Represents one square (one date) in the calendar grid.
struct CalendarDay: Identifiable {
    let id = UUID()                    // Unique ID so SwiftUI can track it
    let date: Date                     // The actual date (June 10, 2025, etc.)
    let belongsToDisplayedMonth: Bool  // Is it in the current month or just padding?
    let status: DayStatus              // What happened that day?
    
    // Convenience: is this the calendar's “today”?
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}

// MARK: – ViewModel for Calendar Logic
// This object figures out which days to show, where to start/end,
// and what status each day has (completed, missed, etc.).
class CalendarViewModel: ObservableObject {
    @Published var displayedMonth: Date      // The month we’re looking at
    @Published var days: [CalendarDay] = []  // The array of day-cells
    
    private let calendar = Calendar.current
    private let completionByDate: [Date: Bool]  // Which days were fully done?
    private let startDate: Date?                // When the challenge began
    
    // Initialize with the data for which days are complete, and when the challenge started.
    init(completionByDate: [Date: Bool], startDate: Date?) {
        self.completionByDate = completionByDate
        self.startDate = startDate
        // Start by showing the current month
        self.displayedMonth = calendar.startOfDay(for: Date())
        generateDays()
    }
    
    // Go backward one month
    func prevMonth() {
        displayedMonth = calendar.date(
            byAdding: .month, value: -1, to: displayedMonth
        ) ?? displayedMonth
        generateDays()
    }
    
    // Go forward one month
    func nextMonth() {
        displayedMonth = calendar.date(
            byAdding: .month, value: 1, to: displayedMonth
        ) ?? displayedMonth
        generateDays()
    }
    
    // Build the `days` array: leading padding, the month’s days, then trailing padding
    private func generateDays() {
        days.removeAll()
        // Find the start of the month and which weekday that is
        guard let monthInterval = calendar.dateInterval(
            of: .month, for: displayedMonth
        ),
              let weekday = calendar.dateComponents(
                [.weekday], from: monthInterval.start
              ).weekday
        else { return }
        
        // Calculate how many “empty” squares before the 1st of the month
        let lead = (weekday - calendar.firstWeekday + 7) % 7
        
        // 1) Leading squares from previous month
        for offset in 0..<lead {
            let date = calendar.date(
                byAdding: .day, value: offset - lead,
                to: monthInterval.start
            )!
            days.append(makeDay(date: date, belongs: false))
        }
        
        // 2) Actual days of this month
        let dayRange = calendar.range(
            of: .day, in: .month, for: displayedMonth
        )!
        for day in dayRange {
            let date = calendar.date(
                byAdding: .day, value: day - 1,
                to: monthInterval.start
            )!
            days.append(makeDay(date: date, belongs: true))
        }
        
        // 3) Trailing squares to fill out the final week row
        while days.count % 7 != 0 {
            let overflow = days.count - lead
            let date = calendar.date(
                byAdding: .day, value: overflow,
                to: monthInterval.start
            )!
            days.append(makeDay(date: date, belongs: false))
        }
    }
    
    // Helper to create a CalendarDay, figuring out its DayStatus
    private func makeDay(date: Date, belongs: Bool) -> CalendarDay {
        let key = calendar.startOfDay(for: date)
        let status: DayStatus
        
        // If it matches the challenge’s reset date
        if let start = startDate,
           calendar.isDate(start, inSameDayAs: date) {
            status = .reset
            
            // If we have completion data for that date
        } else if let done = completionByDate[key] {
            status = done ? .completed : .missed
            
            // If the date is in the future
        } else if date > Date() {
            status = .future
            
            // Otherwise, we have no data
        } else {
            status = .none
        }
        
        return CalendarDay(
            date: date,
            belongsToDisplayedMonth: belongs,
            status: status
        )
    }
}

// MARK: – Calendar View
// This SwiftUI view shows the month header, weekday labels, and the 7×N grid.
struct CalendarView: View {
    @StateObject private var vm: CalendarViewModel    // Our calendar logic helper
    @State private var showPicker = false             // Show month/year picker?
    @State private var selectedDay: CalendarDay?      // Which day was tapped?
    
    // 7 columns, each flexible width
    private let columns = Array(
        repeating: GridItem(.flexible()), count: 7
    )
    // DateFormatter for “June 2025” style
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f
    }()
    
    // Initialize by handing in completion data + start date
    init(completionByDate: [Date: Bool], startDate: Date?) {
        _vm = StateObject(
            wrappedValue: CalendarViewModel(
                completionByDate: completionByDate,
                startDate: startDate
            )
        )
    }
    
    var body: some View {
        VStack {
            // 1) Month navigation header
            HStack {
                Button { vm.prevMonth() } label: {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Button { showPicker = true } label: {
                    Text(dateFormatter.string(from: vm.displayedMonth))
                        .font(.headline)
                }
                Spacer()
                Button { vm.nextMonth() } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
            // Show the month/year picker sheet
            .sheet(isPresented: $showPicker) {
                MonthYearPicker(selected: $vm.displayedMonth)
            }
            
            // 2) Weekday labels: Sun, Mon, Tue…
            let symbols = Calendar.current.shortWeekdaySymbols
            HStack {
                ForEach(symbols, id: \.self) {
                    Text($0).frame(maxWidth: .infinity)
                }
            }
            .font(.caption)
            
            // 3) The grid of days
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(vm.days) { day in
                    DayCell(day: day)
                        .onTapGesture {
                            selectedDay = day  // store tapped day
                        }
                }
            }
            .padding(.horizontal)
            // Swipe to change month
            .gesture(DragGesture().onEnded { g in
                if g.translation.width < -50 { vm.nextMonth() }
                if g.translation.width >  50 { vm.prevMonth() }
            })
        }
        // Show an alert instead of a sheet for details
        .alert(item: $selectedDay) { day in
            Alert(
                title: Text(
                    DateFormatter.localizedString(
                        from: day.date,
                        dateStyle: .medium,
                        timeStyle: .none
                    )
                ),
                message: Text(detailText(for: day.status)),
                dismissButton: .default(Text("OK")) {
                    selectedDay = nil
                }
            )
        }
    }
    
    // Convert a DayStatus into friendly text
    private func detailText(for status: DayStatus) -> String {
        switch status {
        case .completed: return "All tasks completed."
        case .missed:    return "Tasks were missed on this day."
        case .future:    return "Future date—no data yet."
        case .reset:     return "This was a challenge reset day."
        default:         return "No data available."
        }
    }
}

// MARK: – Single Day Cell View
// A circle with a number inside it, colored by status, and a border if it’s today.
struct DayCell: View {
    let day: CalendarDay
    
    var body: some View {
        ZStack {
            // Outer ring: highlights today
            Circle()
                .stroke(
                    day.isToday ? Color.accentColor : .clear,
                    lineWidth: 2
                )
                .background(
                    // Fill color based on status if it’s in this month
                    Circle()
                        .fill(
                            day.belongsToDisplayedMonth
                            ? color(for: day.status)
                            : Color.clear
                        )
                )
                .frame(width: 32, height: 32)
            
            // Day number
            Text("\(Calendar.current.component(.day, from: day.date))")
                .font(.caption)
                .foregroundColor(
                    day.belongsToDisplayedMonth
                    ? .primary
                    : .secondary
                )
        }
    }
    
    // Pick a color for each status
    private func color(for status: DayStatus) -> Color {
        switch status {
        case .completed: return .green.opacity(0.6)
        case .missed:    return .red.opacity(0.6)
        case .future:    return .gray.opacity(0.3)
        case .reset:     return .orange.opacity(0.6)
        default:         return .clear
        }
    }
}

// MARK: – Month/Year Picker
// A simple form that lets you pick a new month and year.
struct MonthYearPicker: View {
    @Binding var selected: Date
    @Environment(\.presentationMode) private var mode
    private let calendar = Calendar.current
    @State private var year: Int
    @State private var monthIndex: Int
    
    // Initialize state from the binding’s current date
    init(selected: Binding<Date>) {
        _selected = selected
        let comps = calendar.dateComponents([.year, .month], from: selected.wrappedValue)
        _year = State(initialValue: comps.year ?? calendar.component(.year, from: Date()))
        _monthIndex = State(initialValue: (comps.month ?? 1) - 1)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Month picker
                Picker("Month", selection: $monthIndex) {
                    ForEach(0..<12, id: \.self) { idx in
                        Text(calendar.monthSymbols[idx]).tag(idx)
                    }
                }
                // Year picker (±5 years around today)
                Picker("Year", selection: $year) {
                    ForEach( (calendar.component(.year, from: Date()) - 5)...(calendar.component(.year, from: Date()) + 5), id: \.self) { yr in
                        Text(String(yr)).tag(yr)
                    }
                }
            }
            .navigationTitle("Select Month & Year")
            .toolbar {
                // Done button: update the binding and close
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        let comps = DateComponents(year: year, month: monthIndex + 1)
                        if let date = calendar.date(from: comps) {
                            selected = date
                        }
                        mode.wrappedValue.dismiss()
                    }
                }
                // Cancel button: just close
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        mode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
// Preview
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(completionByDate: [:], startDate: Date())
    }
}
