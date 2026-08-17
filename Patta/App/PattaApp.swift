//
//  PattaApp.swift
//  Patta
//
//  Created by Paulo Eduardo Barbosa da Silva on 14/08/26.
//

import CoreData
import SwiftUI

@main
struct PattaApp: App {
    @State private var dataController: DataController
    @State private var petViewModel: PetViewModel
    
    init() {
        let controller = DataController.shared
        _dataController = .init(initialValue: controller)
        _petViewModel = .init(initialValue: PetViewModel(name: "", context: controller.container.viewContext))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dataController)
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
