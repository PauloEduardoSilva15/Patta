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
    
    @FetchRequest(sortDescriptors: []) private var pets: FetchedResults<Pet>
    
    let columns = [
        GridItem(.flexible(), spacing: 5),
        GridItem(.flexible(), spacing: 5)
    ]
    
    var body: some View {
        
        @Bindable var registryViewModelBind = registryViewModel
        
        VStack {
            HStack {
                Text("Pets")
                    .font(.title.bold())
                
                Spacer()
                
                Button(action: {
                    showSheet.toggle()
                }) {
                    Image(systemName: "plus")
                        .font(.title.weight(.medium))
                }
                .buttonStyle(.plain)
                .frame(width: 44, height: 44)
                .glassEffect(.regular.tint(.accentColor).interactive())
            }
            .padding()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(pets) { pet in
                        PetCard(pet: pet, viewModel: viewModel)
                            .frame(height: 180)
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
