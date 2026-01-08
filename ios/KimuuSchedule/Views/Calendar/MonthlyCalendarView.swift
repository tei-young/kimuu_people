import SwiftUI

struct MonthlyCalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var showingDailyView = false
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdaySymbols = ["일", "월", "화", "수", "목", "금", "토"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                monthHeader
                weekdayHeader
                calendarGrid
            }
            .navigationTitle("캘린더")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.currentMonth = Date()
                        viewModel.selectedDate = Date()
                        Task {
                            await viewModel.fetchAppointments(for: viewModel.currentMonth)
                        }
                    } label: {
                        Text("오늘")
                    }
                }
            }
            .task {
                await viewModel.fetchUsers()
                await viewModel.fetchAppointments(for: viewModel.currentMonth)
            }
            .navigationDestination(isPresented: $showingDailyView) {
                DailyCalendarView(viewModel: viewModel)
            }
        }
    }
    
    private var monthHeader: some View {
        HStack {
            Button {
                withAnimation {
                    viewModel.currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: viewModel.currentMonth) ?? viewModel.currentMonth
                }
                Task {
                    await viewModel.fetchAppointments(for: viewModel.currentMonth)
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
            }
            
            Spacer()
            
            Text(monthYearString)
                .font(.title2.bold())
            
            Spacer()
            
            Button {
                withAnimation {
                    viewModel.currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: viewModel.currentMonth) ?? viewModel.currentMonth
                }
                Task {
                    await viewModel.fetchAppointments(for: viewModel.currentMonth)
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title2)
            }
        }
        .padding()
    }
    
    private var weekdayHeader: some View {
        HStack {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(symbol == "일" ? .red : (symbol == "토" ? .blue : .primary))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    private var calendarGrid: some View {
        GeometryReader { geometry in
            let totalRows = CGFloat((daysInMonth.count + 6) / 7)
            let availableHeight = geometry.size.height
            let cellHeight = max(50, availableHeight / totalRows - 4)
            
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate),
                            isToday: Calendar.current.isDateInToday(date),
                            userColors: viewModel.hasAppointments(on: date).compactMap { userId in
                                viewModel.users.first { $0.id == userId }?.color
                            },
                            cellHeight: cellHeight
                        )
                        .onTapGesture {
                            viewModel.selectedDate = date
                            showingDailyView = true
                        }
                    } else {
                        Color.clear
                            .frame(height: cellHeight)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: viewModel.currentMonth)
    }
    
    private var daysInMonth: [Date?] {
        let calendar = Calendar.current
        
        guard let monthInterval = calendar.dateInterval(of: .month, for: viewModel.currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        let firstDayOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        var days: [Date?] = []
        
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        var currentDate = firstDayOfMonth
        while currentDate < monthInterval.end {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return days
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let userColors: [String]
    var cellHeight: CGFloat = 50
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 18, weight: isToday ? .bold : .regular))
                .foregroundColor(textColor)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(isSelected ? Color.blue : (isToday ? Color.blue.opacity(0.2) : Color.clear))
                )
            
            HStack(spacing: 2) {
                ForEach(userColors.prefix(4), id: \.self) { color in
                    Circle()
                        .fill(Color(hex: color))
                        .frame(width: 6, height: 6)
                }
            }
            .frame(height: 8)
            
            Spacer(minLength: 0)
        }
        .frame(height: cellHeight)
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        }
        let weekday = Calendar.current.component(.weekday, from: date)
        if weekday == 1 { return .red }
        if weekday == 7 { return .blue }
        return .primary
    }
}

#Preview {
    MonthlyCalendarView()
}
