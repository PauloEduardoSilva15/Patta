//
//  Navigation.swift
//  Patta
//
//  Created by Paulo Eduardo Barbosa da Silva on 16/08/26.
//

import SwiftUI

enum PetRoute: Hashable {
    case detail(PetModel)
    case edit(PetModel)
}

struct Navigation: View {
    
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
//                    Search()
                }
            }
        }
    }
    
    
}

#Preview {
   // Navigation()
        
}


