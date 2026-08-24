//
//  Pets.swift
//  Patta
//
//  Created by Paulo Eduardo Barbosa da Silva on 17/08/26.
//

import SwiftUI
import CoreData


struct Pets: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Pet.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Pet.nome, ascending: true)],
        
    ) var pets: FetchedResults<Pet>
    
    
    var allPets: [String]{
        var items: [String] = []
        
        for pet in pets {
            if let name = pet.nome {
                items.append(name)
            }
        }
       
        
        return items
    }
    
    
    var body: some View {
        NavigationStack{
            List(allPets, id: \.self) { pets in
                Text(pets)
            }
        }.navigationTitle("Meus Pets")
    }
}

#Preview {
    NavigationStack{
        Pets()
    }
    
}
