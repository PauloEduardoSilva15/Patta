//
//  VaccineRegistryFormView.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 19/08/26.
//

import SwiftUI
import CoreData

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
                    Button("Cancelar", role: .cancel) {
                        registryViewModel.cancelEditing()
                        registryViewModel.activePetForSheet = nil
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text(registryViewModel.formTitle)
                        .font(.headline)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        if registryViewModel.saveRegistry(
                            petId: pet.id
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
    let context =
        DataController.shared
            .container
            .viewContext

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

    let vaccineRepository =
        CoreDataVaccineRepository(
            context: context
        )

    let vaccineStore =
        VaccineListStore(
            repository: vaccineRepository
        )

    let registryRepository =
        CoreDataVaccineRegistryRepository(
            context: context
        )

    let registryStore =
        VaccineRegistryListStore(
            repository:
                registryRepository
        )

    VaccineRegistrySheet(pet: pet)
        .environment(
            VaccineRegistryViewModel(
                store: registryStore
            )
        )
        .environment(vaccineStore)
        .environment(
            \.managedObjectContext,
            context
        )
}

