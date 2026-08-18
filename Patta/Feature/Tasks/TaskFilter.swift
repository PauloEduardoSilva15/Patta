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
    
    @State var selectCategory: TaskCategory?
    @State var isPriority: Bool = false
    @State var selectPet: Pet?
    var body: some View {
        NavigationStack{
            Form {
                Section{
                    Picker("Categoria", selection: $selectCategory){
                        Text("Todas").tag(TaskCategory.allCases)
                        Text("Alimentação").tag(TaskCategory.alimentacao)
                        Text("Medicação").tag(TaskCategory.medicamento)
                        Text("Higiene").tag(TaskCategory.higiene)
                        Text("Vacinações").tag(TaskCategory.vacinacao)
                        Text("Acompanhamento Médico").tag(TaskCategory.acompanhamentoMedico)
                    }
                }
                
                Section{
                    Toggle("Tarefa Prioritária", isOn: $isPriority)
                }
                
                Section{
                    Picker("Pet", selection: $selectCategory){
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
