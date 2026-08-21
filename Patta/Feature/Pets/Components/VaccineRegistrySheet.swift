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
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Vaccine.title, ascending: true)]) private var vaccines: FetchedResults<Vaccine>
    
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
                            .tag(Vaccine?.none)
                        
                        ForEach(vaccines) { vaccine in
                            Text(vaccine.title ?? "")
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
                        registryViewModel.activePetForSheet = nil
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Nova Vacina")
                        .font(.headline)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        
                        guard registryViewModel.selectedVaccine != nil else {
                            registryViewModel.errorMessage = "Selecione uma vacina"
                            return
                        }
                        
                        if registryViewModel.saveRegistry(pet: pet) {
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
    let context = DataController.shared.container.viewContext
    let name = "Toto"
    let breed = "Beagle"
    let myPetBirthdate = Calendar.current.date(from: DateComponents(year: 2023, month: 5, day: 10))
    let birthdate = myPetBirthdate
    
    if let uiImage = UIImage(named: "ImageTest") {
        let image = uiImage.pngData()
    }
    
    let pet = PetModel(id: UUID(), name: name, breed: breed, birthdate: birthdate, image: nil)
    
    let repository = CoreDataPetRepository(context: context)
    let store = PetListStore(repository: repository)
    let viewModel = PetViewModel(name: "", store: store)
    
    VaccineRegistrySheet(pet: pet)
        .environment(\.managedObjectContext, context)
        .environment(VaccineRegistryViewModel(context: context))
}

