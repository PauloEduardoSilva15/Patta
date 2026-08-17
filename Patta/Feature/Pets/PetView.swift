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
    @State private var showSheet: Bool = false
    
    @FetchRequest(sortDescriptors: []) private var pets: FetchedResults<Pet>
    
    var body: some View {
        NavigationStack {
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
                
                List {
                    ForEach(pets) { pet in
                        Text(pet.name ?? "")
                    }
                }
            }
            .sheet(isPresented: $showSheet) {
                SheetAddPet()
            }
        }
    }
}

#Preview {
    
    let context = DataController.shared.container.viewContext
    let viewModel = PetViewModel(name: "", context: context)
    
    PetView()
        .environment(viewModel)
        .environment(\.managedObjectContext, context)
}
