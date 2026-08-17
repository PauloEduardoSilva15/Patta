//
//  SheetAddPet.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 17/08/26.
//

import SwiftUI
import CoreData

struct SheetAddPet: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(PetViewModel.self) private var viewModel
    
    var body: some View {
        
        @Bindable var viewModelBind = viewModel
        
        VStack {
            HStack {
                Button {
                    dismiss()
                }label: {
                    Image(systemName: "xmark")
                        .font(.title3.weight(.medium))
                }
                .buttonStyle(.plain)
                .frame(width: 44, height: 44)
                .glassEffect(.regular.interactive())
                
                Spacer()
                
                Text("Novo Pet")
                    .font(.body.weight(.semibold))
                
                Spacer()
                
                Button {
                    do {
                        try viewModel.addNewPet()
                        dismiss()
                    } catch {
                        
                    }
                }label: {
                    Image(systemName: "checkmark")
                        .font(.title3.weight(.medium))
                }
                .buttonStyle(.plain)
                .frame(width: 44, height: 44)
                .glassEffect(.regular.tint(.accentColor).interactive())
            }
            .padding()
            
            Form {
                TextField("Insira o nome", text: $viewModelBind.name)
            }
        }
    }
}

#Preview {
    
    let context = DataController.compartilhado.container.viewContext
    let viewModel = PetViewModel(name: "", context: context)
    
    SheetAddPet()
        .environment(viewModel)
        .environment(\.managedObjectContext, context)
}
