import Foundation

struct User: Codable, Identifiable, Equatable {
    let id: UUID
    let email: String
    let displayName: String
    var color: String
    let isAdmin: Bool
    var treatmentTypes: [String]
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case displayName = "display_name"
        case color
        case isAdmin = "is_admin"
        case treatmentTypes = "treatment_types"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    var initial: String {
        String(displayName.prefix(1))
    }
}

extension User {
    static let mock = User(
        id: UUID(),
        email: "test@kimuu.com",
        displayName: "김원장",
        color: "#4ECDC4",
        isAdmin: false,
        treatmentTypes: Constants.defaultTreatmentTypes,
        createdAt: Date(),
        updatedAt: Date()
    )
    
    static let mockUsers: [User] = [
        User(id: UUID(), email: "kim@kimuu.com", displayName: "김원장", color: "#FF6B6B", isAdmin: false, treatmentTypes: Constants.defaultTreatmentTypes, createdAt: Date(), updatedAt: Date()),
        User(id: UUID(), email: "lee@kimuu.com", displayName: "이원장", color: "#4ECDC4", isAdmin: false, treatmentTypes: Constants.defaultTreatmentTypes, createdAt: Date(), updatedAt: Date()),
        User(id: UUID(), email: "park@kimuu.com", displayName: "박원장", color: "#45B7D1", isAdmin: false, treatmentTypes: Constants.defaultTreatmentTypes, createdAt: Date(), updatedAt: Date()),
        User(id: UUID(), email: "choi@kimuu.com", displayName: "최원장", color: "#96CEB4", isAdmin: false, treatmentTypes: Constants.defaultTreatmentTypes, createdAt: Date(), updatedAt: Date()),
    ]
}
