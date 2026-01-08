import Foundation
import Supabase

@MainActor
final class AppointmentViewModel: ObservableObject {
    @Published var customers: [CustomerInfo] = [CustomerInfo()]
    @Published var treatmentType = ""
    @Published var startTime = Date()
    @Published var endTime = Date()
    @Published var memo = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSaved = false
    
    private let supabase = SupabaseService.shared.client
    
    var customerName: String {
        customers.map { $0.name }.joined(separator: ", ")
    }
    
    var customerPhone: String {
        customers.first?.phone ?? ""
    }
    
    func addCustomer() {
        customers.append(CustomerInfo())
    }
    
    func removeCustomer(at index: Int) {
        guard customers.count > 1 else { return }
        customers.remove(at: index)
    }
    
    func createAppointment(for userId: UUID) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        let dto = AppointmentDTO(
            userId: userId,
            customers: customers,
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
        
        let dto = AppointmentUpdateDTO(
            customers: customers,
            treatmentType: treatmentType,
            startTime: startTime,
            endTime: endTime,
            memo: memo.isEmpty ? nil : memo
        )
        
        do {
            try await supabase
                .from("appointments")
                .update(dto)
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
        customers = appointment.customers
        treatmentType = appointment.treatmentType
        startTime = appointment.startTime
        endTime = appointment.endTime
        memo = appointment.memo ?? ""
    }
    
    func reset() {
        customers = [CustomerInfo()]
        treatmentType = ""
        startTime = Date()
        endTime = Date()
        memo = ""
        errorMessage = nil
        isSaved = false
    }
}
