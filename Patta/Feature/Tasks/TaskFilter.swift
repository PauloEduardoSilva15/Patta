//
//  TaskFilter.swift
//  Patta
//
//  Created by Paulo Eduardo Barbosa da Silva on 18/08/26.
//

import SwiftUI
import CoreData

struct TaskFilter: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Pet.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Pet.name, ascending: true)],
        
    ) var pets: FetchedResults<Pet>
    
    var allItems: [String] {
        var items: [String] = []
        
        for pet in pets {
            if let name = pet.name {
                items.append(name)
            }
        }
        
        return items
    }
    @State var isPriority: Bool = false
    @State var selectPet: Pet?
    var body: some View {
        NavigationStack{
            Form {
                
                Section{
                    Picker("Pet", selection: $selectPet){
                        ForEach(allItems, id: \.self){ pet in
                            Text(pet).tag(pet)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    TaskFilter()
    
}
