import Foundation
import Supabase

@MainActor
final class AppointmentViewModel: ObservableObject {
    @Published var customerName = ""
    @Published var customerPhone = ""
    @Published var treatmentType = ""
    @Published var startTime = Date()
    @Published var endTime = Date()
    @Published var memo = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSaved = false
    
    private let supabase = SupabaseService.shared.client
    
    func createAppointment(for userId: UUID) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        let dto = AppointmentDTO(
            userId: userId,
            customerName: customerName,
            customerPhone: customerPhone,
            treatmentType: treatmentType,
            startTime: startTime,
            endTime: endTime,
            memo: memo.isEmpty ? nil : memo
        )
        
        do {
            try await supabase
                .from("appointments")
                .insert(dto)
                .execute()
            
            isSaved = true
        } catch {
            errorMessage = "일정 추가 실패: \(error.localizedDescription)"
        }
    }
    
    func updateAppointment(id: UUID) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            try await supabase
                .from("appointments")
                .update([
                    "customer_name": customerName,
                    "customer_phone": customerPhone,
                    "treatment_type": treatmentType,
                    "start_time": ISO8601DateFormatter().string(from: startTime),
                    "end_time": ISO8601DateFormatter().string(from: endTime),
                    "memo": memo
                ])
                .eq("id", value: id.uuidString)
                .execute()
            
            isSaved = true
        } catch {
            errorMessage = "일정 수정 실패: \(error.localizedDescription)"
        }
    }
    
    func deleteAppointment(id: UUID) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            try await supabase
                .from("appointments")
                .delete()
                .eq("id", value: id.uuidString)
                .execute()
            
            return true
        } catch {
            errorMessage = "일정 삭제 실패: \(error.localizedDescription)"
            return false
        }
    }
    
    func loadAppointment(_ appointment: Appointment) {
        customerName = appointment.customerName
        customerPhone = appointment.customerPhone
        treatmentType = appointment.treatmentType
        startTime = appointment.startTime
        endTime = appointment.endTime
        memo = appointment.memo ?? ""
    }
    
    func reset() {
        customerName = ""
        customerPhone = ""
        treatmentType = ""
        startTime = Date()
        endTime = Date()
        memo = ""
        errorMessage = nil
        isSaved = false
    }
}
