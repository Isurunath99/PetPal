import SwiftUI

struct ReminderListView: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var navPath: NavigationPath
    @StateObject private var viewModel = ReminderViewModel()
    @State private var showingAddReminder = false
    @State private var selectedMonth = Date()
    
    // Calendar helper
    private let calendar = Calendar.current
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with month/year
                VStack {
                    HStack {
                        Text(monthYearString(from: selectedMonth))
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: {
                            showingAddReminder = true
                        }) {
                            Label("Add Reminder", systemImage: "plus")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding([.horizontal, .top])
                    
                    // Calendar month view
                    CalendarMonthView(
                        selectedMonth: $selectedMonth,
                        reminders: viewModel.reminders
                    )
                    .padding(.horizontal)
                }
                .background(Color(.systemBackground))
                
                // Reminders list
                VStack(alignment: .leading) {
                    Text("Active Reminders")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewModel.reminders.isEmpty {
                        VStack {
                            Spacer()
                            Text("No reminders")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    } else {
                        List {
                            ForEach(viewModel.reminders.filter { !$0.isCompleted }) { reminder in
                                ReminderRow(reminder: reminder) {
                                    Task {
                                        await viewModel.markComplete(reminder, isCompleted: true)
                                    }
                                } deleteAction: {
                                    Task {
                                        await viewModel.deleteReminder(reminder)
                                    }
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .frame(maxHeight: .infinity)
            }
            .navigationTitle("Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.loadReminders()
            }
            .sheet(isPresented: $showingAddReminder) {
                AddReminderView { petName, message, date in
                    Task {
                        if await viewModel.addReminder(petName: petName, message: message, date: date) {
                            showingAddReminder = false
                        }
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // Helper to format month/year
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

// Individual reminder row
struct ReminderRow: View {
    let reminder: PetReminder
    let completeAction: () -> Void
    let deleteAction: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(reminder.petName)
                    .font(.headline)
                Text(reminder.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(formatDate(reminder.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack {
                Button(action: completeAction) {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                }
                
                Button(action: deleteAction) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // Helper to format date
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Calendar month view
struct CalendarMonthView: View {
    @Binding var selectedMonth: Date
    let reminders: [PetReminder]
    
    @State private var selectedDate: Date? = Date()
    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack {
            // Days of week header
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(day == "S" ? .red : .primary)
                }
            }
            .padding(.bottom, 0)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(days(), id: \.self) { date in
                    if let date = date {
                        CalendarDayView(
                            date: date,
                            isSelected: isSameDay(date, selectedDate),
                            isToday: isToday(date),
                            hasReminders: hasReminders(on: date)
                        )
                        .onTapGesture {
                            selectedDate = date
                        }
                    } else {
                        // Empty day (placeholder for days from other months)
                        Text("")
                            .frame(height: 40)
                    }
                }
            }
            
            // Month navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Button(action: {
                    selectedMonth = Date()
                    selectedDate = Date()
                }) {
                    Text("Today")
                }
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.top,0)
        }
        .padding(.vertical)
    }
    
    // Generate days for the month
    private func days() -> [Date?] {
        let firstDayOfMonth = firstDay(of: selectedMonth)
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedMonth)!.count
        
        // Get weekday of first day (0 = Sunday, 1 = Monday, etc.)
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1
        
        var days = [Date?]()
        
        // Add empty slots for days before the first day of month
        for _ in 0..<firstWeekday {
            days.append(nil)
        }
        
        // Add days of the month
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        // Fill the remaining days to complete the grid (42 = 6 weeks)
        while days.count < 42 {
            days.append(nil)
        }
        
        return days
    }
    
    private func firstDay(of date: Date) -> Date {
        return calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
    }
    
    private func isSameDay(_ date1: Date?, _ date2: Date?) -> Bool {
        guard let date1 = date1, let date2 = date2 else { return false }
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    private func isToday(_ date: Date) -> Bool {
        return calendar.isDateInToday(date)
    }
    
    private func hasReminders(on date: Date) -> Bool {
        return reminders.contains { reminder in
            calendar.isDate(reminder.date, inSameDayAs: date)
        }
    }
    
    private func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) {
            selectedMonth = newMonth
        }
    }
    
    private func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) {
            selectedMonth = newMonth
        }
    }
}

// Calendar day view
struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasReminders: Bool
    
    private let calendar = Calendar.current
    
    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(height: 40)
            
            VStack {
                Text("\(dayNumber)")
                    .foregroundColor(textColor)
                
                if hasReminders {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 5, height: 5)
                }
            }
        }
    }
    
    private var dayNumber: Int {
        calendar.component(.day, from: date)
    }
    
    private var isWeekend: Bool {
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 || weekday == 7
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .blue
        } else if isToday {
            return Color.blue.opacity(0.3)
        } else {
            return .clear
        }
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else if isWeekend {
            return .red
        } else {
            return .primary
        }
    }
}
