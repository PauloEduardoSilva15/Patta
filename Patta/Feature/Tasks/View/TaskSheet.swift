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
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Pet.name, ascending: true)]) var pets: FetchedResults<Pet>
    @State private var isShowingDeleteConfirmation = false
    
    var body: some View {
        @Bindable var taskViewModel = taskViewModel
        
        NavigationStack{
            Form {
                TextField("Título", text: $taskViewModel.title)
                TextField("Descrição", text: $taskViewModel.description)
                
                Section {
                    Picker(selection: $taskViewModel.selectedPet, label: Text("Pets")) {
                        
                        Text("Todos")
                            .tag(nil as Pet?)
                        
                        ForEach(pets, id: \.self) { pet in
                            Text(pet.name ?? "Pet sem nome")
                                .tag(Optional(pet))
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
                        
                        Text("Tarefa Prioritária")
                        
                    }
                    .tint(.accent)
                    
                } footer: {
                    Text("Use esta opção para destacar tarefas importantes.")
                }
                
                Section {
                    Toggle("Repetir diariamente", isOn:$taskViewModel.isRecurring)
                        .tint(.accent)
                    
                    
                    if taskViewModel.isRecurring {
                       
                        Toggle("Limitar recorrência", isOn: $taskViewModel.hasRecurrenceLimit)
                            .tint(.accent)
                        if taskViewModel.hasRecurrenceLimit {
                            Stepper("Duração: \(taskViewModel.recurrenceDays) dias", value: $taskViewModel.recurrenceDays, in: 1...12, step: 1)
                        }
                    }
                } header: {
                    Text("Recorrência")
                } footer: {
                    if taskViewModel.isRecurring {
                        Text(
                            """
                            Quando esta tarefa for concluída, ela será \
                            reagendada automaticamente para o próximo dia.
                            """
                        )
                    } else {
                        Text(
                            "Ative esta opção para repetir a tarefa todos os dias."
                        )
                    }
                }
                if let task = taskViewModel.taskBeingEdited {
                    Section {
                        Button("Deletar Tarefa", role: .destructive) {
                            isShowingDeleteConfirmation = true
                        }
                    }
                    .confirmationDialog("Deletar tarefa?", isPresented: $isShowingDeleteConfirmation, titleVisibility: .visible) {
                        Button("Deletar Tarefa", role: .destructive) {
                            if taskViewModel.deleteTask(task) {
                                dismiss()
                            }
                        }
                        
                        Button("Cancelar", role: .cancel) { }
                    } message: {
                        Text("Esta ação não pode ser desfeita.")
                    }
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
    let pet1 = Pet(context: context)
    pet1.name = "Goku"
    let pet2 = Pet(context: context)
    pet2.name = "Nami"
    
    return TaskSheet()
        .environment(TaskViewModel(context: context))
        .environment(\.managedObjectContext, context)
}
