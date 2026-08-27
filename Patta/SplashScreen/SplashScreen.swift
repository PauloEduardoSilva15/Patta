//
//  SplashScreen.swift
//  Patta
//
//  Created by Pedro Canute on 27/08/26.
//

import SwiftUI

struct SplashScreen: View {
    
    @State var scale: CGFloat = 0.55
    @State var logoOpacity: Double = 0
    @State var logoOffset: CGFloat = 45
    
    var body: some View {
        ZStack {
            Color.accent
                .ignoresSafeArea()
            
            
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 250)
                .scaleEffect(scale)
                .offset(y: logoOffset)
                .opacity(logoOpacity)
                .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 10)
        }
        .onAppear {
            withAnimation(.spring(response: 0.9, dampingFraction: 0.6)) {
                scale = 0.5
                logoOpacity = 1
                logoOffset = 0
            }
        }
    }
}

#Preview {
    SplashScreen()
}
