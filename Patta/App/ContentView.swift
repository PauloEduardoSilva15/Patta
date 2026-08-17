//
//  ContentView.swift
//  Patta
//
//  Created by Paulo Eduardo Barbosa da Silva on 14/08/26
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var contexto
    var body: some View {
        TesteTarefa(contexto: contexto)
    }
}

#Preview {
    ContentView()
}
