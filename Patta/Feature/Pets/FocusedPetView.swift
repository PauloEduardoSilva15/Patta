//
//  FocusedPetView.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 19/08/26.
//

import SwiftUI
import CoreData

struct FocusedPetView: View {
    
    @Environment(VaccineRegistryViewModel.self) private var vaccineRegistryViewModel
    
    let pet: PetModel
    let viewModel: PetViewModel
    
    @State private var selectedTab: PetTab = .info
    @Binding var navPath: [PetRoute]
    
    var body: some View {
        
        @Bindable var vaccineViewModelBind = vaccineRegistryViewModel
        
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
                        VaccineListView(pet: pet)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if selectedTab == .vaccines {
                VStack(alignment: .trailing) {
                    Button {
                        vaccineRegistryViewModel.prepareNewRegistry()
                        vaccineRegistryViewModel.activePetForSheet = pet
                    }label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                            .glassEffect(.regular.tint(.accent).interactive())
                    }
                    .buttonStyle(.plain)
                    .zIndex(1)
                }
                .padding(.vertical, 40)
                .padding(.horizontal, 40)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                NavigationLink(value: PetRoute.edit(pet)) {
                    Text("Editar")
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }
}

struct PetInformationView: View {
    
    let pet: PetModel
    let viewModel: PetViewModel
    
    var body: some View {
        Text(pet.name.isEmpty ? "Nome" : pet.name)
            .foregroundStyle(pet.name.isEmpty ? .secondary : .primary)
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
        
        Text((pet.medicalConditions ?? "").isEmpty ? "Condições Médicas" : pet.medicalConditions ?? "")
            .foregroundStyle((pet.medicalConditions ?? "").isEmpty ? .secondary : .primary)
            .padding(12)
    }
}

struct VaccineListView: View {
    let pet: PetModel
    @FetchRequest private var registries: FetchedResults<VaccineRegistry>
    
    init(pet: PetModel) {
        self.pet = pet
        _registries = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \VaccineRegistry.applicationDate, ascending: false)],
            predicate: NSPredicate(format: "pet == %@", pet as! CVarArg)
        )
    }
    
    var body: some View {
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

#Preview {
    @Previewable @State var navPath: [PetRoute] = []
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
    
    FocusedPetView(pet: pet, viewModel: viewModel, navPath: $navPath)
        .environment(VaccineRegistryViewModel(context: context))
}
