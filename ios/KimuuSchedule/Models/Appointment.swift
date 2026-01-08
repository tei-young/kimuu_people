import Foundation

struct CustomerInfo: Codable, Equatable, Identifiable {
    var id = UUID()
    var name: String
    var phone: String
    
    enum CodingKeys: String, CodingKey {
        case name, phone
    }
    
    init(name: String = "", phone: String = "010") {
        self.name = name
        self.phone = phone
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.phone = try container.decode(String.self, forKey: .phone)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(phone, forKey: .phone)
    }
}

struct Appointment: Codable, Identifiable, Equatable {
    let id: UUID
    let userId: UUID
    var customers: [CustomerInfo]
    var treatmentType: String
    var startTime: Date
    var endTime: Date
    var memo: String?
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case customers
        case treatmentType = "treatment_type"
        case startTime = "start_time"
        case endTime = "end_time"
        case memo
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    var customerName: String {
        customers.map { $0.name }.joined(separator: ", ")
    }
    
    var customerPhone: String {
        customers.first?.phone ?? ""
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
    let customers: [CustomerInfo]
    let treatmentType: String
    let startTime: Date
    let endTime: Date
    let memo: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case customers
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
            customers: [CustomerInfo(name: "홍길동", phone: "010-1234-5678")],
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
                        customers: [CustomerInfo(name: "고객\(index + 1)-\(i + 1)", phone: "010-\(1000 + index)-\(5000 + i)")],
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
