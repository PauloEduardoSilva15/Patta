//
//  Navigation.swift
//  Patta
//
//  Created by Paulo Eduardo Barbosa da Silva on 16/08/26.
//

import SwiftUI
import CoreData

enum PetRoute: Hashable {
    case detail(Pet)
    case edit(Pet)
}

struct Navigation: View {
    @Environment(\.managedObjectContext) private var context
    
    var body: some View {
        TabView{
            Tab("Tarefas", systemImage: "calendar"){
                NavigationStack {
                    TaskView()
                    
                }
            }
            Tab("Pets", systemImage: "pawprint.fill"){
                PetView()
            }
            Tab(role: .search){
                NavigationStack{
                    Search()
                }
            }
        }
    }
    
    
}

#Preview {
   // Navigation()
        
}


