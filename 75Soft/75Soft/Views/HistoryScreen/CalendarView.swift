// CalendarView.swift
// 75Soft

import SwiftUI

/// Represents the status of a day in the calendar
enum DayStatus {
    case completed
    case missed
    case future
    case reset
    case none
}

/// Model for a single calendar day cell
struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date
    let belongsToDisplayedMonth: Bool
    let status: DayStatus
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}

/// ViewModel powering the CalendarView
class CalendarViewModel: ObservableObject {
    @Published var displayedMonth: Date
    @Published var days: [CalendarDay] = []
    
    private let calendar = Calendar.current
    private let completionByDate: [Date: Bool]
    private let startDate: Date?
    
    init(completionByDate: [Date: Bool], startDate: Date?) {
        self.completionByDate = completionByDate
        self.startDate = startDate
        self.displayedMonth = calendar.startOfDay(for: Date())
        generateDays()
    }
    
    func prevMonth() {
        displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
        generateDays()
    }
    
    func nextMonth() {
        displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
        generateDays()
    }
    
    private func generateDays() {
        days.removeAll()
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let weekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday
        else { return }
        
        let lead = (weekday - calendar.firstWeekday + 7) % 7
        
        // Leading days
        for offset in 0..<lead {
            let date = calendar.date(
                byAdding: .day,
                value: offset - lead,
                to: monthInterval.start
            )!
            days.append(makeDay(date: date, belongs: false))
        }
        
        // Current month days
        let dayRange = calendar.range(of: .day, in: .month, for: displayedMonth)!
        for day in dayRange {
            let date = calendar.date(
                byAdding: .day,
                value: day - 1,
                to: monthInterval.start
            )!
            days.append(makeDay(date: date, belongs: true))
        }
        
        // Trailing days
        while days.count % 7 != 0 {
            let overflow = days.count - lead
            let date = calendar.date(
                byAdding: .day,
                value: overflow,
                to: monthInterval.start
            )!
            days.append(makeDay(date: date, belongs: false))
        }
    }
    
    private func makeDay(date: Date, belongs: Bool) -> CalendarDay {
        let key = calendar.startOfDay(for: date)
        let status: DayStatus
        if let start = startDate, calendar.isDate(start, inSameDayAs: date) {
            status = .reset
        } else if let done = completionByDate[key] {
            status = done ? .completed : .missed
        } else if date > Date() {
            status = .future
        } else {
            status = .none
        }
        return CalendarDay(date: date, belongsToDisplayedMonth: belongs, status: status)
    }
}

/// The interactive calendar view
struct CalendarView: View {
    @StateObject private var vm: CalendarViewModel
    @State private var showPicker = false
    @State private var selectedDay: CalendarDay?
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f
    }()
    
    init(completionByDate: [Date: Bool], startDate: Date?) {
        _vm = StateObject(wrappedValue: CalendarViewModel(completionByDate: completionByDate, startDate: startDate))
    }
    
    var body: some View {
        VStack {
            // Header with navigation
            HStack {
                Button { vm.prevMonth() } label: { Image(systemName: "chevron.left") }
                Spacer()
                Button { showPicker = true } label: {
                    Text(dateFormatter.string(from: vm.displayedMonth))
                        .font(.headline)
                }
                Spacer()
                Button { vm.nextMonth() } label: { Image(systemName: "chevron.right") }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
            .sheet(isPresented: $showPicker) {
                MonthYearPicker(selected: $vm.displayedMonth)
            }
            
            // Days of week header
            let symbols = Calendar.current.shortWeekdaySymbols
            HStack {
                ForEach(symbols, id: \.self) { Text($0).frame(maxWidth: .infinity) }
            }
            .font(.caption)
            
            // Grid of days
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(vm.days) { day in
                    DayCell(day: day)
                        .onTapGesture { selectedDay = day }
                }
            }
            .padding(.horizontal)
            .gesture(DragGesture().onEnded { g in
                if g.translation.width < -50 { vm.nextMonth() }
                if g.translation.width > 50 { vm.prevMonth() }
            })
        }
        .alert(item: $selectedDay) { day in
            Alert(
                title: Text(DateFormatter.localizedString(
                    from: day.date,
                    dateStyle: .medium,
                    timeStyle: .none
                )),
                message: Text(detailText(for: day.status)),
                dismissButton: .default(Text("OK")) {
                    selectedDay = nil
                }
            )
        }
    }
    
    private func detailText(for status: DayStatus) -> String {
        switch status {
        case .completed: return "All tasks completed."
        case .missed:    return "Tasks were missed on this day."
        case .future:    return "Future date - no data yet."
        case .reset:     return "This was a challenge reset day."
        default:         return "No data available."
        }
    }
}


// MARK: - Subviews

struct DayCell: View {
    let day: CalendarDay
    var body: some View {
        ZStack {
            Circle()
                .stroke(day.isToday ? Color.accentColor : .clear, lineWidth: 2)
                .background(
                    Circle().fill(day.belongsToDisplayedMonth ? color(for: day.status) : Color.clear)
                )
                .frame(width: 32, height: 32)
            Text("\(Calendar.current.component(.day, from: day.date))")
                .font(.caption)
                .foregroundColor(day.belongsToDisplayedMonth ? .primary : .secondary)
        }
    }
    
    private func color(for status: DayStatus) -> Color {
        switch status {
        case .completed: return .green.opacity(0.6)
        case .missed: return .red.opacity(0.6)
        case .future: return .gray.opacity(0.3)
        case .reset: return .orange.opacity(0.6)
        default: return .clear
        }
    }
}

struct DayDetailView: View {
    let day: CalendarDay
    var body: some View {
        VStack(spacing: 16) {
            Text(day.date, style: .date)
                .font(.headline)
            switch day.status {
            case .completed: Text("All tasks completed")
            case .missed: Text("Tasks missed")
            case .future: Text("Future date")
            case .reset: Text("Challenge reset day")
            default: Text("No data")
            }
            Spacer()
        }
        .padding()
    }
}

struct MonthYearPicker: View {
    @Binding var selected: Date
    @Environment(\.presentationMode) private var mode
    private let calendar = Calendar.current
    @State private var year: Int
    @State private var monthIndex: Int
    
    init(selected: Binding<Date>) {
        _selected = selected
        let comps = calendar.dateComponents([.year, .month], from: selected.wrappedValue)
        _year = State(initialValue: comps.year ?? calendar.component(.year, from: Date()))
        _monthIndex = State(initialValue: (comps.month ?? 1) - 1)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Month", selection: $monthIndex) {
                    ForEach(0..<12, id: \.self) { idx in
                        Text(calendar.monthSymbols[idx]).tag(idx)
                    }
                }
                Picker("Year", selection: $year) {
                    ForEach((calendar.component(.year, from: Date())-5)...(calendar.component(.year, from: Date())+5), id: \.self) { yr in
                        Text(String(yr)).tag(yr)
                    }
                }
            }
            .navigationTitle("Select Month & Year")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        let comps = DateComponents(year: year, month: monthIndex+1)
                        if let date = calendar.date(from: comps) {
                            selected = date
                        }
                        mode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { mode.wrappedValue.dismiss() }
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
