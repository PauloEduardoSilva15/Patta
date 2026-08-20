//
//  PendingTasks.swift
//  Patta
//
//  Created by Pedro Canute on 19/08/26.
//

import SwiftUI
import CoreData

struct PendingTasks: View {
    @State private var showTaskSheet: Bool = false
    @Environment(TaskViewModel.self) private var viewModel
    
    let tasks: [Task]
    
    var body: some View {
        List{
            ForEach(tasks) { task in
                LineTask(task: task, onOpenDetails: {
                    viewModel.prepareToEdit(task)
                    showTaskSheet = true
                }, onComplete: {
                    viewModel.completeTask(task)
                })
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button (role: .destructive){
                        viewModel.deleteTask(task)
                    } label: {
                        Label("Deletar", systemImage: "trash")
                    }
                }
                
            }
            
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .sheet(isPresented: $showTaskSheet) {
            TaskSheet()
        }
    }
}
//#Preview {
//    let dataController = DataController.shared
//    let context = dataController.container.viewContext
//    let taskViewModel = TaskViewModel(context: context)
//
//    PendingTasks()
//        .environment(taskViewModel)
//        .environment(
//            \.managedObjectContext,
//             context
//        )
//}
