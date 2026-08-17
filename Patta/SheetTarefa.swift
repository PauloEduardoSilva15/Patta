//
//  SheetTarefa.swift
//  Patta
//
//  Created by Pedro Canute on 17/08/26.
//

import SwiftUI

struct SheetTarefa: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var viewModel: TarefaViewModel
    
    var body: some View {
        NavigationStack{
            Form {
                Section("Informações"){
                    
                    TextField("Nome da Tarefa", text: $viewModel.titulo)
                    TextField("Descrição", text: $viewModel.descricao)
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
                        if viewModel.criarTarefa() {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .disabled(viewModel.titulo.isEmpty)
                }
            }
            
            
        }
    }
}
#Preview {
//    SheetTarefa()
}
