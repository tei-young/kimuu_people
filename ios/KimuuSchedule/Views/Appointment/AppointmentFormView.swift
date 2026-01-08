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
                    TimePickerRow(label: "시작", date: $formViewModel.startTime, baseDate: initialDate)
                    TimePickerRow(label: "종료", date: $formViewModel.endTime, baseDate: initialDate)
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
            .scrollDismissesKeyboard(.interactively)
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
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("완료") {
                            hideKeyboard()
                        }
                    }
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

struct TimePickerRow: View {
    let label: String
    @Binding var date: Date
    let baseDate: Date
    
    @State private var selectedHour: Int = 0
    @State private var selectedMinute: Int = 0
    
    private let hours = Array(0...23)
    private let minutes = [0, 10, 20, 30, 40, 50]
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            
            Picker("시", selection: $selectedHour) {
                ForEach(hours, id: \.self) { hour in
                    Text(String(format: "%02d", hour)).tag(hour)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: selectedHour) { newHour in
                updateDate()
            }
            
            Text(":")
            
            Picker("분", selection: $selectedMinute) {
                ForEach(minutes, id: \.self) { minute in
                    Text(String(format: "%02d", minute)).tag(minute)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: selectedMinute) { newMinute in
                updateDate()
            }
        }
        .onAppear {
            let components = Calendar.current.dateComponents([.hour, .minute], from: date)
            selectedHour = components.hour ?? 0
            let minute = components.minute ?? 0
            selectedMinute = minutes.min(by: { abs($0 - minute) < abs($1 - minute) }) ?? 0
        }
    }
    
    private func updateDate() {
        date = Calendar.current.date(bySettingHour: selectedHour, minute: selectedMinute, second: 0, of: baseDate) ?? date
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
