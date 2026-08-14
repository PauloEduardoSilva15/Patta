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
    let container = NSPersistentContainer(name: "TarefaPet")
    
    init () {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Falha ao carregar o banco de dados: \(error)")
            }
        }
    }
}
