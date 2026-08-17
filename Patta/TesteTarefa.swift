//
//  TesteTarefa.swift
//  Patta
//
//  Created by Pedro Canute on 17/08/26.
//
import CoreData
import SwiftUI

struct TesteTarefa: View {
    
    @State private var mostrarSheetTarefa: Bool = false
    @State private var viewModel: TarefaViewModel
    
    @FetchRequest(sortDescriptors: []) var tarefas: FetchedResults<Tarefa>
    
    init(contexto: NSManagedObjectContext) {
        _viewModel = State(initialValue: TarefaViewModel(contexto: contexto))
    }
    
    var body: some View {
        NavigationStack {
            
            List{
                Text("Quantidade: \(tarefas.count)")
                ForEach(tarefas) { tarefa in
                    linhaDaTarefa(tarefa)
                }
                .onDelete(perform: apagarTarefas)
                
            }
            .navigationTitle("Tarefas")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.prepararNovaTarefa()
                        mostrarSheetTarefa.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $mostrarSheetTarefa) {
                SheetTarefa()
                    .environment(viewModel)
            }
        }
    }
    
    private func linhaDaTarefa(_ tarefa: Tarefa) -> some View {
            HStack {

                VStack(alignment: .leading) {
                    Text(tarefa.titulo!)

                    if let descricao = tarefa.desc,
                       !descricao.isEmpty {
                        Text(descricao)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }

        private func apagarTarefas(at offsets: IndexSet) {
            for indice in offsets {
                viewModel.apagarTarefa(tarefas[indice])
            }
        }
}
#Preview {
//    TesteTarefa()
}
