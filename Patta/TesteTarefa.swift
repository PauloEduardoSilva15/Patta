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
    @Environment(TaskViewModel.self) private var viewModel
  
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
                    PendingTasks()
                case 1:
                    CompletedTasks()
                default:
                    PendingTasks()
                }
            }
            .padding(.horizontal, 8)
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
    let taskViewModel = TaskViewModel(context: context)

    TesteTarefa()
        .environment(taskViewModel)
        .environment(
            \.managedObjectContext,
            context
        )
}
