//
//  ContentView.swift
//  Patta
//
//  Created by Paulo Eduardo Barbosa da Silva on 14/08/26
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "pawprint.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, Pata!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
