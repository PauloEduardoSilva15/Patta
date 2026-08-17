//
//  PattaApp.swift
//  Patta
//
//  Created by Paulo Eduardo Barbosa da Silva on 14/08/26.
//

import CoreData
import SwiftUI

@main
struct PattaApp: App {
    @State private var dataController = DataController.compartilhado
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dataController)
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
