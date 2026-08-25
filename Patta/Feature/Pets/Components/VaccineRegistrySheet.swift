//
//  VaccineRegistryFormView.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 19/08/26.
//

import SwiftUI
import SwiftData

struct VaccineRegistrySheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    @Environment(VaccineRegistryViewModel.self) private var registryViewModel
    @Environment(VaccineListStore.self) private var vaccineListStore
    
    let pet: PetModel
    
    @State private var errorMessage = ""
    @State private var showAlert = false
    
    var body: some View {
        
        @Bindable var registryViewModelBind = registryViewModel
        
        NavigationStack {
            VStack(spacing: 0) {
                Form {
                    Picker("Vacina", selection: $registryViewModelBind.selectedVaccine) {
                        Text("Selecione uma vacina")
                            .tag(VaccineModel?.none)
                        
                        ForEach(vaccineListStore.vaccines) { vaccine in
                            Text(vaccine.title)
                                .tag(Optional(vaccine))
                        }
                    }
                    
                    DatePicker("Data",
                               selection: $registryViewModelBind.applicationDate,
                               in: ...Date.now, displayedComponents: .date)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        registryViewModel.cancelEditing()
                        registryViewModel.activePetForSheet = nil
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(registryViewModel.formTitle)
                        .font(.headline)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        if registryViewModel.saveRegistry(
                            pet: pet
                        ) {
                            registryViewModel.activePetForSheet = nil
                        }
                    }
                }
            }
        }
        .onChange(of: registryViewModel.errorMessage ?? "") { _,error in
            if !error.isEmpty {
                errorMessage = error
                showAlert = true
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Erro"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: PetModel.self, VaccineModel.self, VaccineRegistryModel.self, configurations: config)
    let context = container.mainContext
    
    let pet = PetModel(
        id: UUID(),
        name: "Toto",
        breed: "Beagle",
        birthdate: Calendar.current.date(
            from: DateComponents(
                year: 2023,
                month: 5,
                day: 10
            )
        ),
        image: nil
    )
    
    let vaccineRepository = SwiftDataVaccineRepository(context: context)
    
    let vaccineStore = VaccineListStore(repository: vaccineRepository)
    
    let registryRepository = SwiftDataVaccineRegistryRepository(context: context)
    
    let registryStore = VaccineRegistryListStore(repository: registryRepository)
    
    VaccineRegistrySheet(pet: pet)
        .environment(VaccineRegistryViewModel(store: registryStore))
        .environment(vaccineStore)
        .modelContainer(container)
}

