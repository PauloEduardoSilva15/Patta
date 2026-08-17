//
//  SheetTarefa.swift
//  Patta
//
//  Created by Pedro Canute on 17/08/26.
//

import SwiftUI

struct SheetTarefa: View {
    @Environment(\.dismiss) var dismiss
    
    @Environment(TaskViewModel.self) var viewModel
    
    var body: some View {
        @Bindable var viewModelBindable = viewModel
        NavigationStack{
            Form {
                Section("Informações"){
                    
                    TextField("Nome da Tarefa", text: $viewModelBindable.title)
                    TextField("Descrição", text: $viewModelBindable.description)
                }
            }
            .navigationTitle("Nova Tarefa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        if viewModel.createTask() {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .disabled(viewModel.title.isEmpty)
                }
            }
            
            
        }
    }
}
#Preview {
//    SheetTarefa()
}
