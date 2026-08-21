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
    @State private var taskViewModel: TaskViewModel
    @State private var vaccineRegistryViewModel: VaccineRegistryViewModel
    @State private var vaccineViewModel: VaccineViewModel
    @State private var petListStore: PetListStore
    
    init() {
        let controller = DataController.shared
        let context = controller.container.viewContext
        
        let petRepository = CoreDataPetRepository(context: context)
        let petStore = PetListStore(repository: petRepository)
        
        _dataController = .init(initialValue: controller)
        _petListStore = .init(initialValue: petStore)
        _petViewModel = .init(initialValue: PetViewModel(name: "", store: petStore))
        _taskViewModel = .init(initialValue: TaskViewModel(context: context))
        _vaccineRegistryViewModel = .init(initialValue: VaccineRegistryViewModel(context: context))
        _vaccineViewModel = .init(initialValue: VaccineViewModel(context: context))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dataController)
                .environment(taskViewModel)
                .environment(petViewModel)
                .environment(vaccineViewModel)
                .environment(vaccineRegistryViewModel)
                .environment(petListStore)
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
