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
    @State private var dataController: DataController
    @State private var petViewModel: PetViewModel
    @State private var taskViewModel: TaskViewModel
    
    init() {
        let controller = DataController.shared
        let context = controller.container.viewContext
        _dataController = .init(initialValue: controller)
        _petViewModel = .init(initialValue: PetViewModel(name: "", context: context))
        _taskViewModel = .init(initialValue: TaskViewModel(context: context))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(taskViewModel)
                   .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
