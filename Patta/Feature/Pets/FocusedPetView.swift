//
//  FocusedPetView.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 19/08/26.
//

import SwiftUI
import CoreData

struct FocusedPetView: View {

    let pet: Pet
    let viewModel: PetViewModel
    
    @State private var selectedTab: PetTab = .info
    @State private var openSheet = false
    
    @FetchRequest private var registries: FetchedResults<VaccineRegistry>
    
    init(pet: Pet, viewModel: PetViewModel) {
        self.pet = pet
        self.viewModel = viewModel
        _registries = FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \VaccineRegistry.applicationDate, ascending: false)], predicate: NSPredicate(format: "pet == %@", pet))
    }
    
    var body: some View {
        ZStack {
            if let image = pet.image, let UIImage = UIImage(data: image) {
                GeometryReader { geo in
                    Image(uiImage: UIImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: geo.size.width)
                        .clipped()
                        .ignoresSafeArea()
                }
            }
            
            VStack {
                
                Spacer()
                    VStack(alignment: .leading, spacing: 0) {
                        
                        PetSegmentedControl(selectedTab: $selectedTab)
                            .padding(.bottom, 10)
                        
                        if selectedTab == .info {
                            PetInformationView(pet: pet, viewModel: viewModel)
                        } else {
                            if registries.isEmpty {
                                Text("Não há vacinas registradas.")
                                    .padding(.vertical, 30)
                            } else {
                                ScrollView {
                                    ForEach(registries) { registry in
                                        VaccineCardHistory(vaccineRegistry: registry)
                                            .padding(12)
                                        
                                        if registry != registries.last {
                                            Divider()
                                        }
                                    }
                                }
                                .frame(maxHeight: 320)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if selectedTab == .vaccines {
                VStack(alignment: .trailing) {
                    Button {
                        openSheet.toggle()
                    }label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 44, height: 44)
                    .glassEffect(.regular.tint(.accent).interactive())
                }
                .padding(.vertical, 40)
                .padding(.horizontal, 40)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    
                }label: {
                    Text("Editar")
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $openSheet) {
            VaccineRegistrySheet(pet: pet)
        }
    }
}

struct PetInformationView: View {
    
    let pet: Pet
    let viewModel: PetViewModel
    
    var body: some View {
        Text((pet.name ?? "").isEmpty ? "Nome" : pet.name ?? "")
            .foregroundStyle((pet.name ?? "").isEmpty ? .secondary : .primary)
            .padding(12)
        
        Divider()
        
        Text(pet.birthdate == nil ? "Idade" : viewModel.getAge(birthdate: pet.birthdate ?? Date.now) + " anos")
            .foregroundStyle(pet.birthdate == nil ? .secondary : .primary)
            .padding(12)
        
        Divider()
        
        Text((pet.breed ?? "").isEmpty ? "Raça" : pet.breed ?? "")
            .foregroundStyle((pet.breed ?? "").isEmpty ? .secondary : .primary)
            .padding(12)
        
        Divider()
        
        Text((pet.med_cond ?? "").isEmpty ? "Condições Médicas" : pet.med_cond ?? "")
            .foregroundStyle((pet.med_cond ?? "").isEmpty ? .secondary : .primary)
            .padding(12)
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
    
    let viewModel = PetViewModel(name: "", context: context)
    
    return FocusedPetView(pet: pet, viewModel: viewModel)
}
