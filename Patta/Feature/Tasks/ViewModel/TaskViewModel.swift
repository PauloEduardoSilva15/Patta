//
//  TaskViewModel.swift
//  Patta
//
//  Created by Pedro Canute on 17/08/26.
//

import CoreData
import Observation

@MainActor
@Observable
final class TaskViewModel {
    var title = ""
    var description = ""
    var errorMessage: String?
    var date = Date()
    
    var taskBeingEdited: Task?
    
    private let context: NSManagedObjectContext
    
    var isEditing: Bool {
        taskBeingEdited != nil
    }
    
    var formTitle: String {
        isEditing ? "Editar tarefa" : "Nova tarefa"
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func saveTask() -> Bool {
        let treatedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !treatedTitle.isEmpty else {
            errorMessage = "Digite o título da tarefa."
            return false
        }
        let task: Task
        
        if let taskBeingEdited {
            guard taskBeingEdited.managedObjectContext === context else {
                errorMessage =
                "A tarefa e a ViewModel estão usando contextos diferentes."
                
                print("Contextos diferentes")
                return false
            }
            task = taskBeingEdited
        } else {
            
            task = Task(context: context)
            task.id = UUID()
        }
        
        task.title = treatedTitle
        task.desc = description.trimmingCharacters(in: .whitespacesAndNewlines)
        task.date = date
        
        do {
            try context.save()
            
            clearForm()
            errorMessage = nil
            
            return true
        } catch {
            context.rollback()
            
            let error = error as NSError
            errorMessage = error.localizedDescription
            
            print("Erro Core Data:", error)
            print("Código:", error.code)
            print("Informações:", error.userInfo)
            
            return false
        }
    }
    
    func prepareNewTask() {
        taskBeingEdited = nil
        title = ""
        description = ""
        date = Date()
        errorMessage = nil
    }
    
    func prepareToEdit(_ task: Task) {
        taskBeingEdited = task
        title = task.title ?? ""
        description = task.desc ?? ""
        date = task.date ?? Date()
        errorMessage = nil
    }
    
    func cancelEditing() {
        clearForm()
        errorMessage = nil
    }
    
    func deleteTask(_ task: Task) {
        context.delete(task)
        
        do {
            try context.save()
            
            if taskBeingEdited?.objectID == task.objectID {
                clearForm()
            }
            
            errorMessage = nil
        } catch {
            context.rollback()
            
            errorMessage =
            "Não foi possível apagar a tarefa: \(error.localizedDescription)"
        }
    }
    
    func clearForm() {
        taskBeingEdited = nil
        title = ""
        description = ""
        date = Date()
    }
}
