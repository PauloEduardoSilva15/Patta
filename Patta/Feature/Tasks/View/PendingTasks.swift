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
    
    private var priorityTasks: [Task] {
        tasks.filter { $0.isPriority }
    }
    
    private var nonPriorityTasks: [Task] {
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
                if !priorityTasks.isEmpty {
                    Section {
                        ForEach(priorityTasks, id: \.objectID) { task in
                            LineTask(task: task, onOpenDetails: {
                                viewModel.prepareToEdit(task)
                                showTaskSheet = true
                            }, onComplete: {
                                viewModel.toggleTaskCompletion(task)
                            })
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button (role: .destructive){
                                    if viewModel.deleteTask(task) {
                                        print("Deleted")
                                    }
                                } label: {
                                    Label("Deletar", systemImage: "trash")
                                }
                            }
                        }
                    } header: {
                        Text("Tarefas prioritárias: \(priorityTasksCount)")
                    }
                }
                
                if !nonPriorityTasks.isEmpty {
                    Section {
                        ForEach(nonPriorityTasks, id: \.objectID) { task in
                            LineTask(task: task, onOpenDetails: {
                                viewModel.prepareToEdit(task)
                                showTaskSheet = true
                            }, onComplete: {
                                viewModel.toggleTaskCompletion(task)
                            })
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button (role: .destructive){
                                    if viewModel.deleteTask(task) {
                                        print("Deleted")
                                    }
                                } label: {
                                    Label("Deletar", systemImage: "trash")
                                }
                            }
                        }
                    } header: {
                        Text("Tarefas Pendentes: \(nonPriorityTasksCount)")
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
