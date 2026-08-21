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
    //Pet
    @State private var petViewModel: PetViewModel
    @State private var petListStore: PetListStore
    //Task
    @State private var taskViewModel: TaskViewModel
    //Vaccine
    @State private var vaccineViewModel: VaccineViewModel
    @State private var vaccineListStore: VaccineListStore
    //VaccineRegistry
    @State private var vaccineRegistryViewModel: VaccineRegistryViewModel
    @State private var vaccineRegistryListStore: VaccineRegistryListStore
    
    init() {
        let controller = DataController.shared
        let context = controller.container.viewContext
        
        let petRepository = CoreDataPetRepository(context: context)
        let petStore = PetListStore(repository: petRepository)
        
        let vaccineRepository = CoreDataVaccineRepository(context: context)
        let vaccineStore = VaccineListStore(repository: vaccineRepository)
        
        let vaccineRegistryRepository = CoreDataVaccineRegistryRepository(context: context)
        let vaccineRegistryStore = VaccineRegistryListStore(repository: vaccineRegistryRepository)
        
        _dataController = .init(initialValue: controller)
        _petListStore = .init(initialValue: petStore)
        _petViewModel = .init(initialValue: PetViewModel(name: "", store: petStore))
        _taskViewModel = .init(initialValue: TaskViewModel(context: context))
        _vaccineListStore = .init(initialValue: vaccineStore)
        _vaccineRegistryListStore = .init(initialValue: vaccineRegistryStore)
        _vaccineRegistryViewModel = .init(initialValue: VaccineRegistryViewModel(store: vaccineRegistryStore))
        _vaccineViewModel = .init(initialValue: VaccineViewModel(store: vaccineStore))
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
                .environment(vaccineListStore)
                .environment(vaccineRegistryListStore)
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
