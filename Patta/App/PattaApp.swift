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
    //Search
    @State private var searchViewModel: SearchViewModel
    
    init() {
        
        do {
            container = try ModelContainer(for: PetModel.self, TaskModel.self, VaccineModel.self, VaccineRegistryModel.self)
            
            let seedContext = ModelContext(container)
            let descriptor = FetchDescriptor<VaccineModel>()
            let existingCount = try seedContext.fetchCount(descriptor)
            
            if existingCount == 0 {
                let defaultVaccines = [
                    "V8 (Óctupla Canina)",
                    "V10 (Décupla Canina)",
                    "V12 (Duodécupla Canina)",
                    "Antirrábica Canina",
                    "Giárdia Canina",
                    "Gripe Canina",
                    "Leishmaniose Canina",
                    "Coronavirose Canina",
                    "Parvovirose Canina",
                    "Cinomose",
                    "Hepatite Infecciosa Canina (Adenovírus tipo 1)",
                    "Leptospirose Canina",
                    "Parainfluenza Canina",
                    "Traqueobronquite Infecciosa Canina",
                    "V3 (Tríplice Felina)",
                    "V4 Felina",
                    "V5 Felina",
                    "Leucemia Felina (FeLV)",
                    "Antirrábica Felina",
                    "Clamidiose Felina",
                    "Peritonite Infecciosa Felina (PIF/FIP)",
                    "Panleucopenia Felina",
                    "Rinotraqueíte Felina (Herpesvírus Felino)",
                    "Calicivirose Felina",
                    "Imunodeficiência Felina (FIV)",
                    "Doença de Newcastle",
                    "Bouba Aviária (Varíola Aviária)",
                    "Influenza Aviária",
                    "Bronquite Infecciosa Aviária",
                    "Doença de Marek",
                    "Gumboro (Bursite Infecciosa)",
                    "Reovirose Aviária",
                    "Encefalomielite Aviária",
                    "Clamidiose Aviária (Psitacose)",
                    "Poliomavírus Aviário (PBFD associado)",
                    "Circovírus Aviário (PBFD)",
                    "Coriza Infecciosa das Aves",
                    "Laringotraqueíte Infecciosa Aviária",
                    "Mixomatose",
                    "Doença Hemorrágica Viral do Coelho (VHD/RHDV)",
                    "Pasteurelose do Coelho",
                    "Cinomose (Furão)",
                    "Antirrábica (Furão)",
                    "Enterite Epizoótica do Furão",
                    "Influenza Equina",
                    "Tétano Equino",
                    "Encefalomielite Equina do Leste",
                    "Encefalomielite Equina do Oeste",
                    "Raiva Equina",
                    "Rinopneumonite Equina",
                    "Arterite Viral Equina",
                    "Febre do Nilo Ocidental",
                    "Adenite Equina (Garrotilho)",
                    "Rotavirose Equina",
                    "Febre Aftosa",
                    "Brucelose Bovina",
                    "Raiva dos Herbívoros (Bovina)",
                    "Clostridiose Bovina (Polivalente)",
                    "Botulismo Bovino",
                    "IBR (Rinotraqueíte Infecciosa Bovina)",
                    "BVD (Diarreia Viral Bovina)",
                    "Leptospirose Bovina",
                    "Carbúnculo Sintomático (Manqueira)",
                    "Carbúnculo Hemático (Antraz)",
                    "Pasteurelose Bovina",
                    "Febre Catarral Maligna",
                    "Peste Suína Clássica",
                    "Parvovirose Suína",
                    "Erisipela Suína",
                    "Circovirose Suína (PCV2)",
                    "Micoplasmose Suína",
                    "Rinite Atrófica Suína",
                    "Colibacilose Suína",
                    "Síndrome Reprodutiva e Respiratória Suína (PRRS)",
                    "Clostridiose Ovina/Caprina (Polivalente)",
                    "Ectima Contagioso",
                    "Linfadenite Caseosa",
                    "Raiva dos Herbívoros (Ovina/Caprina)",
                    "Brucelose Caprina",
                    "Vibriose (Peixes)",
                    "Furunculose (Salmonídeos)",
                    "Septicemia Hemorrágica Viral (Peixes)",
                    "Mixomatose (Roedores)",
                    "Antirrábica (Cavalos-marinhos)",
                    "Doença Respiratória Crônica (Roedores)",
                    "Pasteurelose (Porquinho-da-índia)",
                ]
                
                for title in defaultVaccines {
                    let newVaccine = VaccineModel(id: UUID(), title: title)
                    seedContext.insert(newVaccine)
                }
                
                try seedContext.save()
            }
            
            let context = container.mainContext
            
            let petRepository = SwiftDataPetRepository(context: context)
            let petStore = PetListStore(repository: petRepository)
            
            let taskRepository = SwiftDataTaskRepository(context: context)
            let taskStore = TaskListStore(repository: taskRepository)
            
            let vaccineRepository = SwiftDataVaccineRepository(context: context)
            let vaccineStore = VaccineListStore(repository: vaccineRepository)
            
            let vaccineRegistryRepository = SwiftDataVaccineRegistryRepository(context: context)
            let vaccineRegistryStore = VaccineRegistryListStore(repository: vaccineRegistryRepository)
            
            let searchModel = SearchViewModel(petStore: petStore,taskStore: taskStore)
            
            _petListStore = .init(initialValue: petStore)
            _petViewModel = .init(initialValue: PetViewModel(name: "", store: petStore))
            _taskListStore = .init(initialValue: taskStore)
            _taskViewModel = .init(initialValue: TaskViewModel(store: taskStore))
            _vaccineListStore = .init(initialValue: vaccineStore)
            _vaccineRegistryListStore = .init(initialValue: vaccineRegistryStore)
            _vaccineRegistryViewModel = .init(initialValue: VaccineRegistryViewModel(store: vaccineRegistryStore))
            _vaccineViewModel = .init(initialValue: VaccineViewModel(store: vaccineStore))
            _searchViewModel = .init(initialValue: searchModel)
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
