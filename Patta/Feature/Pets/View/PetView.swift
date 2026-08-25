//
//  PetView.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 17/08/26.
//

import SwiftUI
import SwiftData

struct PetView: View {
    
    @Environment(PetViewModel.self) private var viewModel
    @Environment(PetListStore.self) private var petListStore
    @Environment(VaccineRegistryViewModel.self) private var registryViewModel
    
    @State private var showSheet: Bool = false
    
    @State private var navPath = [PetRoute]()
    
    let columns = [
        GridItem(.flexible(), spacing: 5),
        GridItem(.flexible(), spacing: 5)
    ]
    
    var body: some View {
        
        NavigationStack(path: $navPath) {
            @Bindable var registryViewModelBind = registryViewModel
            
            ZStack {
                
                Color.background
                    .ignoresSafeArea()
                
                VStack {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(petListStore.pets) { pet in
                                NavigationLink(value: PetRoute.detail(pet)) {
                                    PetCard(pet: pet, viewModel: viewModel)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
                .sheet(isPresented: $showSheet) {
                    SheetAddPet()
                }
                .sheet(item: $registryViewModelBind.activePetForSheet) { pet in
                    VaccineRegistrySheet(pet: pet)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            viewModel.prepareNewPet()
                            showSheet = true
                        }) {
                            Image(systemName: "plus")
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(.glassProminent)
                    }
                }
            }
            .navigationTitle("Pets")
            .navigationDestination(for: PetRoute.self) { route in
                switch route {
                case .detail(let petToView):
                    FocusedPetView(pet: petToView, viewModel: viewModel, navPath: $navPath)
                case .edit(let petToEdit):
                    EditPetView(pet: petToEdit, viewModel: viewModel, navPath: $navPath, isDismiss: false)
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: PetModel.self, VaccineRegistryModel.self, configurations: config)
    let context = container.mainContext
    
    let repository = SwiftDataPetRepository(context: context)
    let vaccineRepository = SwiftDataVaccineRegistryRepository(context: context)
    let store = PetListStore(repository: repository)
    let viewModel = PetViewModel(name: "", store: store)
    let vaccineRegistryStore = VaccineRegistryListStore(repository: vaccineRepository)
    let registryViewModel = VaccineRegistryViewModel(store: vaccineRegistryStore)
    
    PetView()
        .environment(viewModel)
        .environment(registryViewModel)
        .modelContainer(container)
}
