//
//  TesteTarefa.swift
//  Patta
//
//  Created by Pedro Canute on 17/08/26.
//
import CoreData
import SwiftUI

struct TesteTarefa: View {
    @State var selection = 0
    @State var showTaskSheet = false
    @State private var viewModel:TaskViewModel
    @Environment(\.managedObjectContext) private var context
   
    init(context: NSManagedObjectContext) {
        _viewModel = State(initialValue: TaskViewModel(context: context))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                
                Picker("Tarefas", selection: $selection) {
                    Text("Pendentes")
                        .tag(0)
                    Text("Concluídas")
                        .tag(1)
                }
                .pickerStyle(.segmented)
                
                switch selection {
                case 0:
                    PendingTasks(context: context)
                case 1:
                    CompletedTasks(context: context)
                default:
                    PendingTasks(context: context)
                }
            }
            .padding(.horizontal, 12)
            .navigationTitle("Tarefas")
            .background {
                Color(.background)
                    .ignoresSafeArea()
            }
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
}
#Preview {
    let dataController = DataController.shared
    let context = dataController.container.viewContext
    
    TesteTarefa(context: context)
        .environment(\.managedObjectContext, context)
    
}
