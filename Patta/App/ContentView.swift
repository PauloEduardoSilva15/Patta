//
//  ContentView.swift
//  Patta
//
//  Created by Paulo Eduardo Barbosa da Silva on 14/08/26
//

import SwiftUI

struct ContentView: View {
    
    @State private var showSplash = true
    var splashScreenOpacity: Double { showSplash ? 0 : 1 }
    let waitTime: Double = 1.7
    let fadeTime: Double = 0.7
    
    var body: some View {
        ZStack {
            homeScreen
                .opacity(splashScreenOpacity)
            
            if showSplash {
                SplashScreen()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(waitTime))
            
            withAnimation(.easeInOut(duration: fadeTime)) {
                showSplash = false
            }
        }
            
    }
    
    var homeScreen: some View{
        Navigation()
    }
}

#Preview {
//    ContentView()
}
