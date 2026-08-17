//
//  ContentView.swift
//  Patta
//
//  Created by Paulo Eduardo Barbosa da Silva on 14/08/26
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var context
    var body: some View {
        TesteTarefa(context: context)
    }
}

#Preview {
    ContentView()
}
