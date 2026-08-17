//
//  TarefaViewModel.swift
//  Patta
//
//  Created by Pedro Canute on 17/08/26.
//

import Combine
import CoreData

@MainActor
final class TarefaViewModel: ObservableObject {
    @Published var titulo = ""
    @Published var descricao = ""
    @Published var mensagemDeErro: String?
    
    private let contexto: NSManagedObjectContext
    
    init(contexto: NSManagedObjectContext) {
        self.contexto = contexto
    }
    
    func criarTarefa() -> Bool {
        let tituloTratado = titulo.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !tituloTratado.isEmpty else {
            mensagemDeErro = "Digite o título da tarefa"
            return false
        }
        
        let tarefa = Tarefa(context: contexto)
        
        tarefa.id = UUID()
        tarefa.titulo = tituloTratado
        tarefa.desc = descricao.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            try contexto.save()

            print("Tarefa salva com sucesso")
            print("ID:", tarefa.objectID)

            limparFormulario()
            mensagemDeErro = nil
            return true
        } catch {
            contexto.rollback()

            let erro = error as NSError

            mensagemDeErro = erro.localizedDescription

            print("Erro Core Data:", erro)
            print("Código:", erro.code)
            print("Informações:", erro.userInfo)

            return false
        }
        
    }
    
    func apagarTarefa(_ tarefa: Tarefa) {
        contexto.delete(tarefa)
        salvarAlteracoes()
    }
    
    func prepararNovaTarefa() {
        limparFormulario()
        mensagemDeErro = nil
    }
    
    func salvarAlteracoes() {
        do {
            try contexto.save()
            mensagemDeErro = nil
        } catch {
            contexto.rollback()
            mensagemDeErro = "Não foi possível salvar as alterações: \(error.localizedDescription)"
        }
    }
    
    func limparFormulario() {
        titulo = ""
        descricao = ""
    }
}
