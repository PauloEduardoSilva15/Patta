//
//  Navigation.swift
//  Patta
//
//  Created by Paulo Eduardo Barbosa da Silva on 16/08/26.
//

import SwiftUI

struct Navigation: View {
    var body: some View {
        TabView{
            Tab("Tarefas", systemImage: "calendar"){
                                
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
