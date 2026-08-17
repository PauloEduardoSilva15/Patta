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
    
    @FetchRequest(sortDescriptors: []) var tasks: FetchedResults<Task>
    
    init(context: NSManagedObjectContext) {
        _viewModel = State(initialValue: TaskViewModel(context: context))
    }
    
    var body: some View {
        NavigationStack {
            
            List{
                Text("Quantidade: \(tasks.count)")
                ForEach(tasks) { task in
                    taskLine(task)
                }
                .onDelete(perform: deleteTasks)
                
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
                SheetTarefa()
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
//    TesteTarefa()
}
