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
    
    let pet: Pet
    
    var body: some View {
        
        @Bindable var registryViewModelBind = registryViewModel
        
        VStack(spacing: 0) {
            
            HStack {
                Button {
                    dismiss()
                }label: {
                    Image(systemName: "xmark")
                        .font(.body.weight(.semibold))
                }
                .buttonStyle(.plain)
                .frame(width: 44, height: 44)
                .glassEffect(.regular)
                
                Spacer()
                
                Text("Nova Vacina")
                    .font(.headline)
                
                Spacer()
                
                Button {
                    if registryViewModel.saveRegistry(pet: pet) {
                        dismiss()
                    }
                }label: {
                    Image(systemName: "checkmark")
                        .font(.body.weight(.semibold))
                }
                .buttonStyle(.plain)
                .frame(width: 44, height: 44)
                .glassEffect(.regular.tint(.accent).interactive())
            }
            .padding()
            
            Form {
                Picker(registryViewModel.selectedVaccine?.title ?? "Vacina", selection: $registryViewModelBind.selectedVaccine) {
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
        .onAppear {
            registryViewModel.prepareNewRegistry()
        }
    }
}

#Preview {
    let context = DataController.shared.container.viewContext
    let pet = Pet(context: context)
    
    pet.name = "Toto"
    pet.breed = "Beagle"
    let myPetBirthdate = Calendar.current.date(from: DateComponents(year: 2023, month: 5, day: 10))
    pet.birthdate = myPetBirthdate
    
    if let uiImage = UIImage(named: "ImageTest") {
        pet.image = uiImage.pngData()
    }
    
    return VaccineRegistrySheet(pet: pet)
        .environment(\.managedObjectContext, context)
        .environment(VaccineRegistryViewModel(context: context))
}

