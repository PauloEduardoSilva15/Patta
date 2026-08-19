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
            self.seedDefaultVaccines()
            
            print("Core Data carregado em:", description.url?.absoluteString ?? "URL desconhecida")
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
    }
    
    private func seedDefaultVaccines() {
        let context = container.viewContext
        
        let request = Vaccine.fetchRequest()
        request.fetchLimit = 1
        
        let alreadySeeded = (try? context.count(for: request))
        guard alreadySeeded == 0 else { return }
        
        let defaultVaccines = [
            "Antirrábica",
            "V8 (Múltipla)"
        ]
        
        for title in defaultVaccines {
            let vaccine = Vaccine(context: context)
            vaccine.id = UUID()
            vaccine.title = title
        }
        
        do {
            try context.save()
        } catch {
            print("Erro ao popular vacinas padrão: \(error.localizedDescription)")
        }
    }
}
