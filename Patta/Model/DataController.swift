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
        
        container.loadPersistentStores { [weak self] description, error in
            if let nsError = error as NSError? {
                fatalError(
                    """
                    Não foi possível abrir o Core Data.

                    Código: \(nsError.code)
                    Descrição: \(nsError.localizedDescription)
                    Detalhes: \(nsError.userInfo)
                    """
                )
            }

            print(
                "Core Data carregado em:",
                description.url?.absoluteString ?? "URL desconhecida"
            )

            self?.seedDefaultVaccines()
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
