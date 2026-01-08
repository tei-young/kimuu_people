import SwiftUI

enum AppointmentFormMode {
    case add
    case edit(Appointment)
}

struct AppointmentFormView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var viewModel: CalendarViewModel
    @StateObject private var formViewModel = AppointmentViewModel()
    
    let initialDate: Date
    let initialHour: Int?
    let mode: AppointmentFormMode
    
    var body: some View {
        NavigationStack {
            Form {
                Section("고객 정보") {
                    TextField("고객명", text: $formViewModel.customerName)
                    TextField("010-0000-0000", text: $formViewModel.customerPhone)
                        .keyboardType(.phonePad)
                        .onChange(of: formViewModel.customerPhone) { newValue in
                            let formatted = newValue.formattedPhoneNumber
                            if formatted != newValue {
                                formViewModel.customerPhone = formatted
                            }
                        }
                }
                
                Section("시술 정보") {
                    Picker("시술 종류", selection: $formViewModel.treatmentType) {
                        Text("선택하세요").tag("")
                        ForEach(treatmentOptions, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                }
                
                Section("시간") {
                    DatePicker("시작", selection: $formViewModel.startTime, displayedComponents: [.hourAndMinute])
                    DatePicker("종료", selection: $formViewModel.endTime, displayedComponents: [.hourAndMinute])
                }
                
                Section("메모") {
                    TextField("메모 (선택)", text: $formViewModel.memo, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                if let error = formViewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(isEditMode ? "일정 수정" : "일정 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        Task {
                            await saveAppointment()
                        }
                    }
                    .disabled(!isValid || formViewModel.isLoading)
                }
            }
            .onAppear {
                setupInitialValues()
            }
            .onChange(of: formViewModel.isSaved) { saved in
                if saved {
                    Task {
                        await viewModel.fetchAppointments(for: viewModel.currentMonth)
                    }
                    dismiss()
                }
            }
        }
    }
    
    private var treatmentOptions: [String] {
        authViewModel.currentUser?.treatmentTypes ?? Constants.defaultTreatmentTypes
    }
    
    private var isEditMode: Bool {
        if case .edit = mode { return true }
        return false
    }
    
    private var isValid: Bool {
        !formViewModel.customerName.isEmpty &&
        !formViewModel.customerPhone.isEmpty &&
        !formViewModel.treatmentType.isEmpty &&
        formViewModel.endTime > formViewModel.startTime
    }
    
    private func setupInitialValues() {
        switch mode {
        case .add:
            let hour = initialHour ?? 10
            formViewModel.startTime = initialDate.setting(hour: hour, minute: 0)
            formViewModel.endTime = initialDate.setting(hour: hour + 1, minute: 0)
            formViewModel.treatmentType = treatmentOptions.first ?? ""
            formViewModel.customerPhone = "010"
        case .edit(let appointment):
            formViewModel.loadAppointment(appointment)
        }
    }
    
    private func saveAppointment() async {
        guard let userId = authViewModel.currentUser?.id else { return }
        
        switch mode {
        case .add:
            await formViewModel.createAppointment(for: userId)
        case .edit(let appointment):
            await formViewModel.updateAppointment(id: appointment.id)
        }
    }
}

#Preview {
    AppointmentFormView(
        viewModel: CalendarViewModel(),
        initialDate: Date(),
        initialHour: nil,
        mode: .add
    )
    .environmentObject(AuthViewModel())
}
