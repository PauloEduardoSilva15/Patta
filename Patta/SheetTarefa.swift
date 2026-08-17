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
                Section("Data"){
                    DatePicker("Data", selection: $viewModelBindable.date, displayedComponents: .date)
                }
            }
            .navigationTitle(viewModel.formTitle)
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
                        if viewModel.saveTask() {
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
