import SwiftUI

struct AppointmentDetailView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var appointment: Appointment
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @StateObject private var appointmentViewModel = AppointmentViewModel()
    
    init(appointment: Appointment, viewModel: CalendarViewModel) {
        self._appointment = State(initialValue: appointment)
        self._viewModel = ObservedObject(initialValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(appointment.customers.enumerated()), id: \.element.id) { index, customer in
                    Section(appointment.customers.count == 1 ? "고객 정보" : "고객 \(index + 1)") {
                        LabeledContent("고객명", value: customer.name)
                        LabeledContent("연락처", value: customer.phone.formattedPhoneNumber)
                    }
                }
                
                Section("시술 정보") {
                    LabeledContent("시술 종류", value: appointment.treatmentType)
                    LabeledContent("시간", value: appointment.timeRangeText)
                    LabeledContent("소요 시간", value: "\(appointment.durationMinutes)분")
                }
                
                if let memo = appointment.memo, !memo.isEmpty {
                    Section("메모") {
                        Text(memo)
                    }
                }
                
                Section("담당") {
                    if let user = viewModel.users.first(where: { $0.id == appointment.userId }) {
                        HStack {
                            Circle()
                                .fill(Color(hex: user.color))
                                .frame(width: 12, height: 12)
                            Text(user.displayName)
                        }
                    }
                }
            }
            .navigationTitle("일정 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("닫기") {
                        dismiss()
                    }
                }
                if canEdit {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button {
                                showingEditSheet = true
                            } label: {
                                Label("수정", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive) {
                                showingDeleteAlert = true
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet, onDismiss: {
                if let updated = viewModel.appointments.first(where: { $0.id == appointment.id }) {
                    appointment = updated
                }
            }) {
                AppointmentFormView(
                    viewModel: viewModel,
                    initialDate: appointment.startTime,
                    initialHour: nil,
                    mode: .edit(appointment)
                )
            }
            .alert("일정 삭제", isPresented: $showingDeleteAlert) {
                Button("취소", role: .cancel) { }
                Button("삭제", role: .destructive) {
                    Task {
                        if await appointmentViewModel.deleteAppointment(id: appointment.id) {
                            await viewModel.fetchAppointments(for: viewModel.currentMonth)
                            dismiss()
                        }
                    }
                }
            } message: {
                Text("이 일정을 삭제하시겠습니까?")
            }
        }
    }
    
    private var canEdit: Bool {
        guard let currentUser = authViewModel.currentUser else { return false }
        return currentUser.isAdmin || currentUser.id == appointment.userId
    }
}

#Preview {
    AppointmentDetailView(
        appointment: Appointment.mock(for: User.mock.id),
        viewModel: CalendarViewModel()
    )
    .environmentObject(AuthViewModel())
}
