//
//  TaskSheet.swift
//  Patta
//
//  Created by Pedro Canute on 18/08/26.
//
import CoreData
import SwiftUI

struct TaskSheet: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(TaskViewModel.self) var taskViewModel
    
    var body: some View {
        @Bindable var taskViewModel = taskViewModel
        
        NavigationStack{
            Form {
                TextField("Título", text: $taskViewModel.title)
                TextField("Descrição", text: $taskViewModel.description)
                
                Section {
                    Text("Pet")
                }
                
                Section {
                    
                    Picker(selection: $taskViewModel.selectedCategory, label: Text("Categoria")) {
                        ForEach(TaskCategory.allCases, id: \.self) {
                            Text($0.title)
                        }
                    }
                    
                }
                
                Section {
                    Toggle("Agendar Tarefa", isOn: $taskViewModel.usesCustomDate)
                        .tint(.accent)
                    if taskViewModel.usesCustomDate {
                        DatePicker("Data", selection: $taskViewModel.date)
                            .environment(\.locale, Locale(identifier: "pt_BR"))
                    }
                }
                
                Section {
                    Toggle(isOn: $taskViewModel.isPriority) {
                        HStack(spacing: 8) {
                            Text("Tarefa Prioritária")
                            
                            Image(systemName: "pawprint.fill")
                                .foregroundStyle(.red)
                                .accessibilityHidden(true)
                        }
                    }
                    .tint(.accent)
                    
                } footer: {
                    Text("Use esta opção para destacar tarefas importantes")
                }
                
                Section {
                    Toggle("Recorrência", isOn: $taskViewModel.isRecurring)
                        .tint(.accent)
                }
            }
            .navigationTitle(taskViewModel.formTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        if taskViewModel.saveTask() {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accent)
                    
                }
            }
        }
    }
}
#Preview {
    let dataController = DataController.shared
    let context = dataController.container.viewContext
    
    TaskSheet()
        .environment(TaskViewModel(context: context))
        .environment(\.managedObjectContext, context)
}
