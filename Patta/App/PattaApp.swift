//
//  PattaApp.swift
//  Patta
//
//  Created by Paulo Eduardo Barbosa da Silva on 14/08/26.
//

import SwiftData
import SwiftUI

@main
@MainActor
struct PattaApp: App {
    
    let container: ModelContainer
    
    @State private var dataController: DataController
    //Pet
    @State private var petViewModel: PetViewModel
    @State private var petListStore: PetListStore
    //Task
    @State private var taskViewModel: TaskViewModel
    @State private var taskListStore: TaskListStore
    //Vaccine
    @State private var vaccineViewModel: VaccineViewModel
    @State private var vaccineListStore: VaccineListStore
    //VaccineRegistry
    @State private var vaccineRegistryViewModel: VaccineRegistryViewModel
    @State private var vaccineRegistryListStore: VaccineRegistryListStore
    
    init() {
        
        do {
            container = try ModelContainer(for: PetModel.self)
            
            let context = container.mainContext
            
            let petRepository = SwiftDataPetRepository(context: context)
            let petStore = PetListStore(repository: petRepository)
            
            let taskRepository = CoreDataTaskRepository(context: context)
            let taskStore = TaskListStore(repository: taskRepository)
            
            let vaccineRepository = CoreDataVaccineRepository(context: context)
            let vaccineStore = VaccineListStore(repository: vaccineRepository)
            
            let vaccineRegistryRepository = CoreDataVaccineRegistryRepository(context: context)
            let vaccineRegistryStore = VaccineRegistryListStore(repository: vaccineRegistryRepository)
            
            _petListStore = .init(initialValue: petStore)
            _petViewModel = .init(initialValue: PetViewModel(name: "", store: petStore))
            _taskListStore = .init(initialValue: taskStore)
            _taskViewModel = .init(initialValue: TaskViewModel(store: taskStore))
            _vaccineListStore = .init(initialValue: vaccineStore)
            _vaccineRegistryListStore = .init(initialValue: vaccineRegistryStore)
            _vaccineRegistryViewModel = .init(initialValue: VaccineRegistryViewModel(store: vaccineRegistryStore))
            _vaccineViewModel = .init(initialValue: VaccineViewModel(store: vaccineStore))
        } catch {
            fatalError("Erro ao inicializar o ModelContainer: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(taskViewModel)
                .environment(taskListStore)
                .environment(petViewModel)
                .environment(vaccineViewModel)
                .environment(vaccineRegistryViewModel)
                .environment(petListStore)
                .environment(vaccineListStore)
                .environment(vaccineRegistryListStore)
        }
        .modelContainer(container)
    }
}
