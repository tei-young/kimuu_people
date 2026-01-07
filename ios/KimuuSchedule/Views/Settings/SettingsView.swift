import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingColorSettings = false
    @State private var showingTreatmentSettings = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                if let user = authViewModel.currentUser {
                    Section("내 정보") {
                        HStack {
                            Circle()
                                .fill(Color(hex: user.color))
                                .frame(width: 40, height: 40)
                            
                            VStack(alignment: .leading) {
                                Text(user.displayName)
                                    .font(.headline)
                                Text(user.email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Section("설정") {
                        Button {
                            showingColorSettings = true
                        } label: {
                            HStack {
                                Label("내 색상", systemImage: "paintpalette")
                                Spacer()
                                Circle()
                                    .fill(Color(hex: user.color))
                                    .frame(width: 20, height: 20)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .foregroundColor(.primary)
                        
                        Button {
                            showingTreatmentSettings = true
                        } label: {
                            HStack {
                                Label("시술 종류 관리", systemImage: "list.bullet")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                Section {
                    Button("로그아웃", role: .destructive) {
                        showingLogoutAlert = true
                    }
                }
            }
            .navigationTitle("설정")
            .sheet(isPresented: $showingColorSettings) {
                ColorSettingsView()
            }
            .sheet(isPresented: $showingTreatmentSettings) {
                TreatmentSettingsView()
            }
            .alert("로그아웃", isPresented: $showingLogoutAlert) {
                Button("취소", role: .cancel) { }
                Button("로그아웃", role: .destructive) {
                    Task {
                        await authViewModel.logout()
                    }
                }
            } message: {
                Text("로그아웃 하시겠습니까?")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
}
