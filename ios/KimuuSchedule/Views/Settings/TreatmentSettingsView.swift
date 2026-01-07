import SwiftUI

struct TreatmentSettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var newTreatment = ""
    @State private var showingAddAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(Array(viewModel.treatmentTypes.enumerated()), id: \.offset) { index, type in
                        Text(type)
                    }
                    .onMove { source, destination in
                        viewModel.moveTreatmentType(from: source, to: destination)
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { viewModel.removeTreatmentType(at: $0) }
                    }
                } header: {
                    Text("내 시술 종류")
                } footer: {
                    Text("드래그하여 순서를 변경하거나, 스와이프하여 삭제할 수 있습니다.")
                }
                
                Section {
                    Button {
                        showingAddAlert = true
                    } label: {
                        Label("시술 종류 추가", systemImage: "plus")
                    }
                }
                
                Section {
                    Button("기본값으로 초기화") {
                        viewModel.treatmentTypes = Constants.defaultTreatmentTypes
                    }
                }
            }
            .navigationTitle("시술 종류 관리")
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
                                await viewModel.updateTreatmentTypes(userId: userId)
                            }
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .alert("시술 종류 추가", isPresented: $showingAddAlert) {
                TextField("시술 종류명", text: $newTreatment)
                Button("취소", role: .cancel) {
                    newTreatment = ""
                }
                Button("추가") {
                    viewModel.addTreatmentType(newTreatment)
                    newTreatment = ""
                }
            }
            .onAppear {
                if let user = authViewModel.currentUser {
                    viewModel.treatmentTypes = user.treatmentTypes
                }
            }
            .onChange(of: viewModel.isSaved) { saved in
                if saved {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    TreatmentSettingsView()
        .environmentObject(AuthViewModel())
}
