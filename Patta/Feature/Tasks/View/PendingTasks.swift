//
//  PendingTasks.swift
//  Patta
//
//  Created by Pedro Canute on 19/08/26.
//

import SwiftUI

struct PendingTasks: View {
    @Environment(TaskViewModel.self) private var viewModel
    @State private var showTaskSheet: Bool = false
    
    let tasks: [TaskModel]
    
    private var priorityTasks: [TaskModel] {
        tasks.filter { $0.isPriority }
    }
    
    private var nonPriorityTasks: [TaskModel] {
        tasks.filter { !$0.isPriority }
    }
    
    var priorityTasksCount: Int {
        priorityTasks.count
    }
    
    var nonPriorityTasksCount: Int {
        nonPriorityTasks.count
    }
    var body: some View {
        List{
            if tasks.isEmpty {
                Text("Não há tarefas agendadas")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            } else {
                prioritySection
                nonPrioritySection
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .sheet(isPresented: $showTaskSheet) {
            TaskSheet()
        }
    }
    
    @ViewBuilder
    private var prioritySection: some View {
        if !priorityTasks.isEmpty {
            Text("Tarefas Prioritárias: \(priorityTasksCount)")
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))

            ForEach(priorityTasks) { task in
                taskRow(task)
            }
        }
    }
    
    @ViewBuilder
    private var nonPrioritySection: some View {
        if !nonPriorityTasks.isEmpty {
            Text("Tarefas pendentes: \(nonPriorityTasksCount)")
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))

            ForEach(nonPriorityTasks) { task in
                taskRow(task)
            }
        }
    }
    
    private func taskRow(_ task: TaskModel) -> some View {
        LineTask(task: task,onOpenDetails: {
                       viewModel.prepareToEdit(task)
                       showTaskSheet = true
                   },
                   onComplete: {
                       viewModel.toggleTaskCompletion(task)
                   }
               )
               .listRowSeparator(.hidden)
               .listRowBackground(Color.clear)
               .listRowInsets(EdgeInsets(top: 4,leading: 0, bottom: 4, trailing: 0))
               .swipeActions(
                   edge: .trailing,
                   allowsFullSwipe: true
               ) {
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
