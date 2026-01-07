import SwiftUI

struct DailyCalendarView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @State private var showingAddSheet = false
    @State private var selectedAppointment: Appointment?
    @State private var showingFilterSheet = false
    @State private var currentPage = 0
    @State private var selectedHour: Int? = nil
    
    private let hourHeight: CGFloat = 60
    
    var body: some View {
        VStack(spacing: 0) {
            dateHeader
            filterAndPageIndicator
            calendarContent
        }
        .navigationTitle(dateString)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    selectedHour = nil
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AppointmentFormView(
                viewModel: viewModel,
                initialDate: viewModel.selectedDate,
                initialHour: selectedHour,
                mode: .add
            )
        }
        .sheet(item: $selectedAppointment) { appointment in
            AppointmentDetailView(
                appointment: appointment,
                viewModel: viewModel
            )
        }
        .gesture(magnificationGesture)
    }
    
    private var dateHeader: some View {
        HStack {
            Button {
                viewModel.selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: viewModel.selectedDate) ?? viewModel.selectedDate
            } label: {
                Image(systemName: "chevron.left")
            }
            
            Spacer()
            
            Text(dateString)
                .font(.headline)
            
            Spacer()
            
            Button {
                viewModel.selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: viewModel.selectedDate) ?? viewModel.selectedDate
            } label: {
                Image(systemName: "chevron.right")
            }
        }
        .padding()
    }
    
    private var filterAndPageIndicator: some View {
        HStack {
            Button {
                showingFilterSheet = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                    Text("필터")
                        .font(.caption)
                }
            }
            .sheet(isPresented: $showingFilterSheet) {
                UserFilterSheet(viewModel: viewModel)
                    .presentationDetents([.medium])
            }
            
            Spacer()
            
            Menu {
                ForEach(TimeScale.allCases, id: \.self) { scale in
                    Button {
                        viewModel.timeScale = scale
                    } label: {
                        HStack {
                            Text(scale.displayName)
                            if viewModel.timeScale == scale {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(viewModel.timeScale.displayName)
                        .font(.caption)
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(8)
            }
            
            if viewModel.visibleUsers.count > Constants.Calendar.maxStaffsPerPage {
                HStack(spacing: 4) {
                    ForEach(0..<pageCount, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    private var calendarContent: some View {
        ScrollViewReader { proxy in
            ScrollView {
                HStack(alignment: .top, spacing: 0) {
                    timeColumn
                    staffColumns
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    proxy.scrollTo(Constants.Calendar.defaultScrollHour, anchor: .top)
                }
            }
        }
    }
    
    private var timeColumn: some View {
        VStack(spacing: 0) {
            ForEach(0..<24, id: \.self) { hour in
                Text(String(format: "%02d:00", hour))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 50, height: viewModel.timeScale.rowHeight * CGFloat(60 / viewModel.timeScale.rawValue))
                    .id(hour)
            }
        }
    }
    
    private var staffColumns: some View {
        let usersToShow = Array(viewModel.visibleUsers.prefix(Constants.Calendar.maxStaffsPerPage))
        
        return HStack(spacing: 1) {
            ForEach(usersToShow) { user in
                StaffColumn(
                    user: user,
                    appointments: viewModel.appointmentsForUser(user.id, on: viewModel.selectedDate),
                    timeScale: viewModel.timeScale,
                    onAppointmentTap: { appointment in
                        selectedAppointment = appointment
                    },
                    onEmptyTap: { hour in
                        selectedHour = hour
                        showingAddSheet = true
                    }
                )
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if viewModel.visibleUsers.count > Constants.Calendar.maxStaffsPerPage {
                        if value.translation.width < -50 && currentPage < pageCount - 1 {
                            currentPage += 1
                        } else if value.translation.width > 50 && currentPage > 0 {
                            currentPage -= 1
                        }
                    }
                }
        )
    }
    
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onEnded { scale in
                if scale > 1.2 {
                    viewModel.zoomIn()
                } else if scale < 0.8 {
                    viewModel.zoomOut()
                }
            }
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: viewModel.selectedDate)
    }
    
    private var pageCount: Int {
        (viewModel.visibleUsers.count + Constants.Calendar.maxStaffsPerPage - 1) / Constants.Calendar.maxStaffsPerPage
    }
}

struct StaffColumn: View {
    let user: User
    let appointments: [Appointment]
    let timeScale: TimeScale
    let onAppointmentTap: (Appointment) -> Void
    let onEmptyTap: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Text(user.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity)
                .background(Color(hex: user.color).opacity(0.3))
            
            ZStack(alignment: .topLeading) {
                VStack(spacing: 0) {
                    ForEach(0..<24, id: \.self) { hour in
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: timeScale.rowHeight * CGFloat(60 / timeScale.rawValue))
                            .overlay(
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 0.5),
                                alignment: .top
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onEmptyTap(hour)
                            }
                    }
                }
                
                ForEach(appointments) { appointment in
                    AppointmentBlockView(
                        appointment: appointment,
                        color: Color(hex: user.color),
                        timeScale: timeScale
                    )
                    .onTapGesture {
                        onAppointmentTap(appointment)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct UserFilterSheet: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button("전체 선택") {
                        viewModel.selectAllUsers()
                    }
                    Button("전체 해제") {
                        viewModel.clearUserFilter()
                    }
                }
                
                Section("원장 선택") {
                    ForEach(viewModel.users) { user in
                        HStack {
                            Circle()
                                .fill(Color(hex: user.color))
                                .frame(width: 12, height: 12)
                            
                            Text(user.displayName)
                            
                            Spacer()
                            
                            if viewModel.filteredUserIds.isEmpty || viewModel.filteredUserIds.contains(user.id) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.toggleUserFilter(user.id)
                        }
                    }
                }
            }
            .navigationTitle("원장 필터")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DailyCalendarView(viewModel: CalendarViewModel())
    }
}
