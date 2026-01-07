import Foundation
import Supabase

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = true
    @Published var currentUser: User?
    @Published var errorMessage: String?
    
    private let supabase = SupabaseService.shared.client
    
    func checkSession() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let session = try await supabase.auth.session
            await fetchCurrentUser(authId: session.user.id)
            isAuthenticated = true
        } catch {
            isAuthenticated = false
            currentUser = nil
        }
    }
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let session = try await supabase.auth.signIn(email: email, password: password)
            await fetchCurrentUser(authId: session.user.id)
            isAuthenticated = true
        } catch {
            errorMessage = "로그인 실패: \(error.localizedDescription)"
        }
    }
    
    func logout() async {
        do {
            try await supabase.auth.signOut()
            isAuthenticated = false
            currentUser = nil
        } catch {
            errorMessage = "로그아웃 실패: \(error.localizedDescription)"
        }
    }
    
    private func fetchCurrentUser(authId: UUID) async {
        do {
            let users: [User] = try await supabase
                .from("users")
                .select()
                .eq("id", value: authId.uuidString)
                .execute()
                .value
            
            currentUser = users.first
        } catch {
            errorMessage = "사용자 정보 조회 실패"
        }
    }
}
