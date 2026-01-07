import Foundation

struct Customer: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let phone: String
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case phone
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

extension Customer {
    static let mock = Customer(
        id: UUID(),
        name: "홍길동",
        phone: "010-1234-5678",
        createdAt: Date(),
        updatedAt: Date()
    )
}
