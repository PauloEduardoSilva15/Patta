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
                    Toggle("Repetir diariamente", isOn:$taskViewModel.isRecurring)
                    .tint(.accent)

                    if taskViewModel.isRecurring {
                        Label("Recorrência diária", systemImage: "repeat")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
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
