import SwiftUI

struct TreatmentSettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var newTreatment = ""
    @State private var showingAddAlert = false
    @State private var showingEditAlert = false
    @State private var editingIndex: Int? = nil
    @State private var editingText = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(Array(viewModel.treatmentTypes.enumerated()), id: \.offset) { index, type in
                        HStack {
                            Text(type)
                            Spacer()
                            Image(systemName: "pencil")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editingIndex = index
                            editingText = type
                            showingEditAlert = true
                        }
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
                    Text("탭하여 수정, 드래그하여 순서 변경, 스와이프하여 삭제할 수 있습니다.")
                }
                
                Section {
                    Button {
                        showingAddAlert = true
                    } label: {
                        Label("시술 종류 추가", systemImage: "plus")
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
                                await authViewModel.refreshCurrentUser()
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
            .alert("시술 종류 수정", isPresented: $showingEditAlert) {
                TextField("시술 종류명", text: $editingText)
                Button("취소", role: .cancel) {
                    editingIndex = nil
                    editingText = ""
                }
                Button("저장") {
                    if let index = editingIndex, !editingText.isEmpty {
                        viewModel.treatmentTypes[index] = editingText
                    }
                    editingIndex = nil
                    editingText = ""
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
