//
//  CompletedTasks.swift
//  Patta
//
//  Created by Pedro Canute on 19/08/26.
//

import CoreData
import SwiftUI

struct CompletedTasks: View {

    @State private var showTaskSheet = false
    @Environment(TaskViewModel.self) private var viewModel

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Task.completedAt,ascending: false)], predicate: NSPredicate(format: "isComplete == YES"),animation: .default) private var completedTasks: FetchedResults<Task>

    var body: some View {
        NavigationStack {
            List {
                ForEach(completedTasks) { task in
                    LineTask(task: task, onOpenDetails: {
                        viewModel.prepareToEdit(task)
                        showTaskSheet = true
                    }, onComplete: {
                        viewModel.completeTask(task)
                    })
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(
                        EdgeInsets(
                            top: 6,
                            leading: 12,
                            bottom: 6,
                            trailing: 12
                        )
                    )
                    .swipeActions(
                        edge: .leading,
                        allowsFullSwipe: true
                    ) {
                        Button {
                            viewModel.prepareToEdit(task)
                            showTaskSheet = true
                        } label: {
                            Label(
                                "Ver detalhes",
                                systemImage: "info"
                            )
                        }
                    }
                    .swipeActions(
                        edge: .trailing,
                        allowsFullSwipe: true
                    ) {
                        Button(role: .destructive) {
                            viewModel.deleteTask(task)
                        } label: {
                            Label(
                                "Deletar",
                                systemImage: "trash"
                            )
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background {
                Color(.background)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $showTaskSheet) {
                TaskSheet()
            }
        }
    }
}

#Preview {
    let dataController = DataController.shared
    let context = dataController.container.viewContext
    let taskViewModel = TaskViewModel(context: context)
    let _ = {
        let task = Task(context: context)
        let pet = Pet(context: context)
        pet.name = "Nami"

        task.title = "Dar Zenrelia"
        task.date = Date()
        task.pet = pet
        task.appliesToAllPets = false
        task.isComplete = true
    }()

    CompletedTasks()
        .environment(taskViewModel)
        .environment(
            \.managedObjectContext,
            context
        )
}
