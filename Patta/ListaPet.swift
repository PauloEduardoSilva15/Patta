//
//  ListaPet.swift
//  Patta
//
//  Created by Pedro Canute on 15/08/26.
//
import CoreData
import SwiftUI

struct ListaPet: View {
    @EnvironmentObject var controlador: DataController
    @FetchRequest(sortDescriptors: []) var pets: FetchedResults<Pet>
    
    var body: some View {
        List {
            ForEach(pets, id: \.self) { pet in
                Text(pet.nome!)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive){
                            apagarPet(pet: pet)
                        } label: {
                            Label("Apagar", systemImage: "trash")
                        }
                    }
            }
            
        }
    }
    
    func apagarPet(pet: Pet) {
        let container = controlador.container.viewContext
        
        container.delete(pet)
        
        do {
            try controlador.salvar()
        } catch {
            container.rollback()
            print("Erro ao apagar pet: \(error.localizedDescription)")
        }
    }
}
#Preview {
    ListaPet()
}
