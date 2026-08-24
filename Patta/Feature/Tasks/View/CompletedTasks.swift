//
//  CompletedTasks.swift
//  Patta
//
//  Created by Pedro Canute on 19/08/26.
//

import SwiftUI

struct CompletedTasks: View {
    @Environment(TaskViewModel.self)
    private var viewModel

    @State private var showTaskSheet = false

    let tasks: [TaskModel]

    var body: some View {
        List {
            if tasks.isEmpty {
                Text("Não há tarefas concluídas")
                .foregroundStyle(.secondary)
                .frame( maxWidth: .infinity,alignment: .center )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            } else {
                ForEach(tasks) { task in
                    taskRow(task)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .sheet(isPresented: $showTaskSheet) {
            TaskSheet()
        }
    }

    private func taskRow(_ task: TaskModel ) -> some View {
        LineTask(task: task, onOpenDetails: {
                viewModel.prepareToEdit(task)
                showTaskSheet = true
            },
            onComplete: {
                viewModel.toggleTaskCompletion(task)
            }
        )
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4,trailing: 0))
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                _ = viewModel.deleteTask(task)
            } label: {
                Label(
                    "Deletar",
                    systemImage: "trash"
                )
            }
        }
    }
}
