import Foundation
import SwiftUI
import Supabase

@MainActor
final class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var currentMonth: Date = Date()
    @Published var appointments: [Appointment] = []
    @Published var users: [User] = []
    @Published var filteredUserIds: Set<UUID> = []
    @Published var timeScale: TimeScale = .hour
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseService.shared.client
    
    var visibleUsers: [User] {
        if filteredUserIds.isEmpty {
            return users
        }
        return users.filter { filteredUserIds.contains($0.id) }
    }
    
    var appointmentsForSelectedDate: [Appointment] {
        let calendar = Calendar.current
        return appointments.filter { appointment in
            calendar.isDate(appointment.startTime, inSameDayAs: selectedDate)
        }
    }
    
    func fetchUsers() async {
        do {
            let fetchedUsers: [User] = try await supabase
                .from("users")
                .select()
                .execute()
                .value
            
            users = fetchedUsers
        } catch {
            errorMessage = "원장 목록 조회 실패"
        }
    }
    
    func fetchAppointments(for month: Date) async {
        isLoading = true
        defer { isLoading = false }
        
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return
        }
        
        let formatter = ISO8601DateFormatter()
        let startString = formatter.string(from: startOfMonth)
        let endString = formatter.string(from: endOfMonth)
        
        do {
            let fetchedAppointments: [Appointment] = try await supabase
                .from("appointments")
                .select()
                .gte("start_time", value: startString)
                .lte("start_time", value: endString)
                .execute()
                .value
            
            appointments = fetchedAppointments
        } catch {
            errorMessage = "일정 조회 실패"
        }
    }
    
    func zoomIn() {
        timeScale = timeScale.zoomIn()
    }
    
    func zoomOut() {
        timeScale = timeScale.zoomOut()
    }
    
    func toggleUserFilter(_ userId: UUID) {
        if filteredUserIds.contains(userId) {
            filteredUserIds.remove(userId)
        } else {
            filteredUserIds.insert(userId)
        }
    }
    
    func selectAllUsers() {
        filteredUserIds = Set(users.map { $0.id })
    }
    
    func clearUserFilter() {
        filteredUserIds.removeAll()
    }
    
    func appointmentsForUser(_ userId: UUID, on date: Date) -> [Appointment] {
        let calendar = Calendar.current
        return appointments.filter { appointment in
            appointment.userId == userId && calendar.isDate(appointment.startTime, inSameDayAs: date)
        }
    }
    
    func hasAppointments(on date: Date) -> [UUID] {
        let calendar = Calendar.current
        let userIdsWithAppointments = appointments
            .filter { calendar.isDate($0.startTime, inSameDayAs: date) }
            .map { $0.userId }
        return Array(Set(userIdsWithAppointments))
    }
    
    func colorForUser(_ userId: UUID) -> Color {
        guard let user = users.first(where: { $0.id == userId }) else {
            return .gray
        }
        return Color(hex: user.color)
    }
}
