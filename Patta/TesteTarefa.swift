//
//  TesteTarefa.swift
//  Patta
//
//  Created by Pedro Canute on 17/08/26.
//
import CoreData
import SwiftUI

struct TesteTarefa: View {
    
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
                    })
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
            .background {
                Color(.background)
                    .ignoresSafeArea(edges: .all)
            }
            .navigationTitle("Tarefas")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.prepareNewTask()
                        showTaskSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showTaskSheet) {
                TaskSheet()
                    .environment(viewModel)
            }
        }
    }
    
    private func taskLine(_ task: Task) -> some View {
        HStack {
            
            VStack(alignment: .leading) {
                Text(task.title!)
                
                if let description = task.desc,
                   !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            viewModel.deleteTask(tasks[index])
        }
    }
}
#Preview {
    let dataController = DataController.shared
    let context = dataController.container.viewContext
    
    TesteTarefa(context: context)
        .environment(\.managedObjectContext, context)
    
}
