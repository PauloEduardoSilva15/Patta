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
                NavigationStack {
                    TaskView(context: context)
                    
                }
            }
            Tab("Pets", systemImage: "pawprint.fill"){
                NavigationStack {
                    PetView()
                }
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
    Navigation()
}


