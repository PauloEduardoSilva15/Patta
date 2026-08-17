//
//  Navigation.swift
//  Patta
//
//  Created by Paulo Eduardo Barbosa da Silva on 16/08/26.
//

import SwiftUI
import CoreData

struct Navigation: View {
    @Environment(\.managedObjectContext) private var contexto
    
    var body: some View {
        TabView{
            Tab("Tarefas", systemImage: "calendar"){
                TesteTarefa(contexto: contexto)
            }
            Tab("Pets", systemImage: "pawprint.fill"){
                                
            }
            Tab(role: .search){
                Search()
            }
        }
    }
    
    
}

#Preview {
    Navigation()
}


