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
    @State private var viewModel: TaskViewModel

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Task.completedAt,ascending: false)], predicate: NSPredicate(format: "isComplete == YES"),animation: .default) private var completedTasks: FetchedResults<Task>

    init(context: NSManagedObjectContext) {
        _viewModel = State(
            initialValue: TaskViewModel(context: context)
        )
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(completedTasks) { task in
                    LineTask(task: task) {
                        viewModel.completeTask(task)
                    }
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
                    .environment(viewModel)
            }
        }
    }
}

#Preview {
    let dataController = DataController.shared
    let context = dataController.container.viewContext
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

    CompletedTasks(context: context)
        .environment(\.managedObjectContext, context)
}
