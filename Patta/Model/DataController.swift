//
//  DataController.swift
//  Patta
//
//  Created by Pedro Canute on 14/08/26.
//

import CoreData
import Combine

@Observable
class DataController {
    static let shared = DataController()
    
    let container: NSPersistentContainer
    
    private init () {
        container = NSPersistentContainer(name: "TarefaPet")
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Falha ao carregar o banco de dados: \(error)")
            }
            
            print("Core Data carregado em:", description.url?.absoluteString ?? "URL desconhecida")
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
    }
}
