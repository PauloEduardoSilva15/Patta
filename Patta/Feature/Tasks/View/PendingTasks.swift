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
    @State private var viewModel: TaskViewModel
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Task.date, ascending: true)]) var tasks: FetchedResults<Task>
    
    init(context: NSManagedObjectContext) {
        _viewModel = State(initialValue: TaskViewModel(context: context))
    }
    
    var body: some View {
        NavigationStack {
            List{
            
                ForEach(tasks) { task in
                    LineTask(task: task, onComplete: {
                        viewModel.completeTask(task)
                    } ) { TaskDetails()}
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            viewModel.prepareToEdit(task)
                            showTaskSheet.toggle()
                        } label: {
                            Label("Ver detalhes", systemImage: "info")
                        }
                    }
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
            
        }
    }
}
#Preview {
    let dataController = DataController.shared
    let context = dataController.container.viewContext
    
    PendingTasks(context:  context )
}
