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
    var usesCustomDate = false
    var selectedCategory: TaskCategory = .alimentacao
    var isPriority = false
    var isRecurring = false
    
    var taskBeingEdited: Task?
    
    private let context: NSManagedObjectContext
    
    var isEditing: Bool {
        taskBeingEdited != nil
    }
    
    var formTitle: String {
        isEditing ? "Editar Tarefa" : "Nova Tarefa"
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
        let now = Date()
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
            task.createdAt = now
        }
        
        task.title = treatedTitle
        task.desc = description.trimmingCharacters(in: .whitespacesAndNewlines)
        task.usesCustomDate = usesCustomDate
        
        if usesCustomDate {
            task.date = date
        } else {
            task.date = task.createdAt ?? now
            
        }
        
        task.taskCategory = selectedCategory
        task.isPriority = isPriority
        task.isRecurring = isRecurring
        
        do {
            try context.save()
            resetForm()
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
        resetForm()
    }
    
    func prepareToEdit(_ task: Task) {
        
        guard task.managedObjectContext === context else {
            errorMessage = "A tarefa e a ViewModel estão usando contextos diferentes."
            return
        }
        
        taskBeingEdited = task
        title = task.title ?? ""
        description = task.desc ?? ""
        date = task.date ?? Date()
        usesCustomDate = task.usesCustomDate
        selectedCategory = task.taskCategory ?? .alimentacao
        isPriority = task.isPriority
        isRecurring = task.isRecurring
        errorMessage = nil
    }
    
    func cancelEditing() {
        resetForm()
    }
    
    func deleteTask(_ task: Task) {
        context.delete(task)
        
        do {
            try context.save()
            
            if taskBeingEdited?.objectID == task.objectID {
                resetForm()
            }
            
            errorMessage = nil
        } catch {
            context.rollback()
            errorMessage = "Não foi possível apagar a tarefa: \(error.localizedDescription)"
        }
    }
    
    private func resetForm() {
        taskBeingEdited = nil
        title = ""
        description = ""
        date = Date()
        usesCustomDate = false
        selectedCategory = .alimentacao
        isPriority = false
        isRecurring = false
        errorMessage = nil
    }
    
    private func nextDailyDate(after scheduledDate: Date, relativeTo now: Date) -> Date? {
        let calendar = Calendar.current
        var nextDate = scheduledDate
        
        repeat {
            guard let calculatedDate = calendar.date(byAdding: .day, value: 1, to: nextDate) else {
                return nil
            }
            nextDate = calculatedDate
        } while nextDate <= now
        
        return nextDate
    }
    
    func completeTask(_ task: Task) {
        
        guard task.managedObjectContext === context else {
            errorMessage = "A tarefa e a ViewModel estão usando contextos diferentes."
            return
        }
        
        let now = Date()
        
        if task.isRecurring {
            let currentDate = task.date ?? now
            
            guard let nextDate = nextDailyDate(after: currentDate, relativeTo: now) else {
                errorMessage = "Não foi possível calcular a próxima data."
                return
            }
            
            task.date = nextDate
            task.isComplete = false
        } else {
            task.isComplete = true
            task.completedAt = now
        }
        
        do {
            try context.save()
            errorMessage = nil
        } catch {
            context.rollback()
            errorMessage = "Não foi possível marcar a tarefa como concluída: \(error.localizedDescription)"
        }
    }
}
