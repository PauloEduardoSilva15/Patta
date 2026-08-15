//
//  DataController.swift
//  Patta
//
//  Created by Pedro Canute on 14/08/26.
//

import CoreData
import Foundation
import Combine

class DataController: ObservableObject {
    static let compartilhado = DataController()
    
    let container: NSPersistentContainer
    
    private init () {
        container = NSPersistentContainer(name: "TarefaPet")
        
        container.loadPersistentStores { descricao, erro in
            if let erro = erro {
                print("Falha ao carregar o banco de dados: \(erro)")
            }
            
            print("Core Data carregado em:", descricao.url?.absoluteString ?? "URL desconhecida")
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
    }
}

extension DataController {
    func salvar() throws {
        guard container.viewContext.hasChanges else { return }
        
        do {
            try container.viewContext.save()
        } catch {
            print("Falha ao salvar o contexto: \(error.localizedDescription)")
        }
    }
    
    func deletar(objeto: NSManagedObject) {
        
        container.viewContext.delete(objeto)
        
        do {
           try salvar()
        } catch {
            container.viewContext.rollback()
            print("Falha ao deletar o objeto: \(error.localizedDescription)")
        }
    }
}

