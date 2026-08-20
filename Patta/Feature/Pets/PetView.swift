//
//  PetView.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 17/08/26.
//

import SwiftUI
import CoreData

struct PetView: View {
    
    @Environment(PetViewModel.self) private var viewModel: PetViewModel
    @Environment(VaccineRegistryViewModel.self) private var registryViewModel
    
    @State private var showSheet: Bool = false
    
    @State private var navPath = [PetRoute]()
    
    @FetchRequest(sortDescriptors: []) private var pets: FetchedResults<Pet>
    
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
                            ForEach(pets) { pet in
                                NavigationLink(value: PetRoute.detail(pet)) {
                                    PetCard(pet: pet, viewModel: viewModel)
                                        .frame(height: 180)
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
                            showSheet.toggle()
                        }) {
                            Image(systemName: "plus")
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
                    EditPetView(pet: petToEdit, viewModel: viewModel, navPath: $navPath)
                }
            }
        }
    }
}

#Preview {
    
    let context = DataController.shared.container.viewContext
    let viewModel = PetViewModel(name: "", context: context)
    let registryViewModel = VaccineRegistryViewModel(context: context)
    
    PetView()
        .environment(viewModel)
        .environment(registryViewModel)
        .environment(\.managedObjectContext, context)
}
