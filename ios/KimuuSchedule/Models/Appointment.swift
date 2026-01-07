import Foundation

struct Appointment: Codable, Identifiable, Equatable {
    let id: UUID
    let userId: UUID
    var customerName: String
    var customerPhone: String
    var treatmentType: String
    var startTime: Date
    var endTime: Date
    var memo: String?
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case customerName = "customer_name"
        case customerPhone = "customer_phone"
        case treatmentType = "treatment_type"
        case startTime = "start_time"
        case endTime = "end_time"
        case memo
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    var durationMinutes: Int {
        Int(endTime.timeIntervalSince(startTime) / 60)
    }
    
    var timeRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
}

struct AppointmentDTO: Codable {
    let userId: UUID
    let customerName: String
    let customerPhone: String
    let treatmentType: String
    let startTime: Date
    let endTime: Date
    let memo: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case customerName = "customer_name"
        case customerPhone = "customer_phone"
        case treatmentType = "treatment_type"
        case startTime = "start_time"
        case endTime = "end_time"
        case memo
    }
}

extension Appointment {
    static func mock(for userId: UUID, at date: Date = Date()) -> Appointment {
        let calendar = Calendar.current
        var startComponents = calendar.dateComponents([.year, .month, .day], from: date)
        startComponents.hour = 10
        startComponents.minute = 0
        let startTime = calendar.date(from: startComponents)!
        let endTime = calendar.date(byAdding: .hour, value: 1, to: startTime)!
        
        return Appointment(
            id: UUID(),
            userId: userId,
            customerName: "홍길동",
            customerPhone: "010-1234-5678",
            treatmentType: "눈썹문신",
            startTime: startTime,
            endTime: endTime,
            memo: "첫 방문 고객",
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    static func mockAppointments(for users: [User], on date: Date = Date()) -> [Appointment] {
        let calendar = Calendar.current
        var appointments: [Appointment] = []
        
        for (index, user) in users.enumerated() {
            let baseHour = 9 + (index * 2)
            
            for i in 0..<2 {
                var startComponents = calendar.dateComponents([.year, .month, .day], from: date)
                startComponents.hour = baseHour + (i * 3)
                startComponents.minute = 0
                
                if let startTime = calendar.date(from: startComponents),
                   let endTime = calendar.date(byAdding: .minute, value: 90, to: startTime) {
                    appointments.append(Appointment(
                        id: UUID(),
                        userId: user.id,
                        customerName: "고객\(index + 1)-\(i + 1)",
                        customerPhone: "010-\(1000 + index)-\(5000 + i)",
                        treatmentType: Constants.defaultTreatmentTypes[i % 3],
                        startTime: startTime,
                        endTime: endTime,
                        memo: nil,
                        createdAt: Date(),
                        updatedAt: Date()
                    ))
                }
            }
        }
        
        return appointments
    }
}
