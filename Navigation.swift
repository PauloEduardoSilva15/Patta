//
//  Navigation.swift
//  Patta
//
//  Created by Paulo Eduardo Barbosa da Silva on 16/08/26.
//

import SwiftUI
import CoreData

struct Navigation: View {
    @Environment(\.managedObjectContext) private var context
    
    var body: some View {
        TabView{
            Tab("Tarefas", systemImage: "calendar"){
                TesteTarefa()
            }
            Tab("Pets", systemImage: "pawprint.fill"){
                PetView()
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


