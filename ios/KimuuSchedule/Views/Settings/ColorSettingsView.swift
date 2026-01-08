import SwiftUI

struct ColorSettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var users: [User] = []
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 4)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                currentColorSection
                colorPaletteSection
                Spacer()
            }
            .padding()
            .navigationTitle("내 색상")
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
                            if let userId = authViewModel.currentUser?.id {
                                await viewModel.updateColor(userId: userId)
                                await authViewModel.refreshCurrentUser()
                            }
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .task {
                await loadUsers()
            }
            .onChange(of: viewModel.isSaved) { saved in
                if saved {
                    dismiss()
                }
            }
        }
    }
    
    private var currentColorSection: some View {
        VStack(spacing: 12) {
            Text("현재 색상")
                .font(.headline)
            
            Circle()
                .fill(Color(hex: viewModel.selectedColor))
                .frame(width: 80, height: 80)
                .overlay(
                    Circle()
                        .stroke(Color.primary.opacity(0.2), lineWidth: 2)
                )
        }
    }
    
    private var colorPaletteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("색상 선택")
                .font(.headline)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(Constants.colorPalette, id: \.self) { color in
                    ColorButton(
                        color: color,
                        isSelected: viewModel.selectedColor == color,
                        isAvailable: viewModel.isColorAvailable(color)
                    ) {
                        if viewModel.isColorAvailable(color) {
                            viewModel.selectedColor = color
                        }
                    }
                }
            }
            
            Text("다른 원장님이 사용 중인 색상은 선택할 수 없습니다")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func loadUsers() async {
        let supabase = SupabaseService.shared.client
        do {
            let fetchedUsers: [User] = try await supabase
                .from("users")
                .select()
                .execute()
                .value
            
            users = fetchedUsers
            
            if let currentUser = authViewModel.currentUser {
                viewModel.loadSettings(for: currentUser, allUsers: fetchedUsers)
            }
        } catch {
            print("Failed to load users: \(error)")
        }
    }
}

struct ColorButton: View {
    let color: String
    let isSelected: Bool
    let isAvailable: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color(hex: color))
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.primary : Color.clear, lineWidth: 3)
                )
                .overlay(
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .opacity(isSelected ? 1 : 0)
                )
                .overlay(
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .opacity(isAvailable ? 0 : 1)
                )
                .opacity(isAvailable ? 1 : 0.4)
        }
        .disabled(!isAvailable)
    }
}

#Preview {
    ColorSettingsView()
        .environmentObject(AuthViewModel())
}
