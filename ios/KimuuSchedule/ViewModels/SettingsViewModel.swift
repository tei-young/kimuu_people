import Foundation
import Supabase

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var selectedColor: String = ""
    @Published var treatmentTypes: [String] = []
    @Published var usedColors: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSaved = false
    
    private let supabase = SupabaseService.shared.client
    
    func loadSettings(for user: User, allUsers: [User]) {
        selectedColor = user.color
        treatmentTypes = user.treatmentTypes
        usedColors = Set(allUsers.filter { $0.id != user.id }.map { $0.color })
    }
    
    func updateColor(userId: UUID) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            try await supabase
                .from("users")
                .update(["color": selectedColor])
                .eq("id", value: userId.uuidString)
                .execute()
            
            isSaved = true
        } catch {
            errorMessage = "색상 변경 실패"
        }
    }
    
    func updateTreatmentTypes(userId: UUID) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            try await supabase
                .from("users")
                .update(["treatment_types": treatmentTypes])
                .eq("id", value: userId.uuidString)
                .execute()
            
            isSaved = true
        } catch {
            errorMessage = "시술 종류 변경 실패"
        }
    }
    
    func addTreatmentType(_ type: String) {
        guard !type.isEmpty && !treatmentTypes.contains(type) else { return }
        treatmentTypes.append(type)
    }
    
    func removeTreatmentType(at index: Int) {
        guard treatmentTypes.count > 1 else { return }
        treatmentTypes.remove(at: index)
    }
    
    func moveTreatmentType(from source: IndexSet, to destination: Int) {
        treatmentTypes.move(fromOffsets: source, toOffset: destination)
    }
    
    func isColorAvailable(_ color: String) -> Bool {
        !usedColors.contains(color) || color == selectedColor
    }
}
