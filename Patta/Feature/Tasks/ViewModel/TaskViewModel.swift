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
    var selectedPet: Pet?
    var isPriority = false
    var isRecurring = false
    var hasRecurrenceLimit = false
    var recurrenceDays = 7
    
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
        
        if let selectedPet {
            guard selectedPet.managedObjectContext === context else {
                errorMessage = "O pet e a ViewModel estão usando contextos diferentes."
                return false
            }
        }
        task.appliesToAllPets = selectedPet == nil
        task.pet = selectedPet
        task.usesCustomDate = usesCustomDate
        
        if usesCustomDate {
            task.date = date
        } else {
            task.date = task.createdAt ?? now
            
        }
        
        task.isPriority = isPriority
        task.isRecurring = isRecurring
        
        if !isRecurring || !hasRecurrenceLimit {
            task.recurrenceEndDate = nil
        } else {
            guard let startDate = task.date else {
                errorMessage = "Data inválida."
                return false
            }
            let daysToAdd = recurrenceDays
            
            guard let endDate = Calendar.current.date(byAdding: .day, value: daysToAdd, to: startDate) else {
                errorMessage = "Não foi possível calcular o final da recorrência."
                return false
            }
            task.recurrenceEndDate = endDate
            
        }
        
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
        
        if task.appliesToAllPets {
            selectedPet = nil
        } else {
            selectedPet = task.pet
        }
        
        taskBeingEdited = task
        title = task.title ?? ""
        description = task.desc ?? ""
        date = task.date ?? Date()
        usesCustomDate = task.usesCustomDate
        isPriority = task.isPriority
        isRecurring = task.isRecurring
        hasRecurrenceLimit = task.recurrenceEndDate != nil
        if let startDate = task.date,
           let endDate = task.recurrenceEndDate {
            
            let calendar = Calendar.current
            
            let normalizedStartDate = calendar.startOfDay(
                for: startDate
            )
            
            let normalizedEndDate = calendar.startOfDay(
                for: endDate
            )
            
            let difference = calendar.dateComponents(
                [.day],
                from: normalizedStartDate,
                to: normalizedEndDate
            ).day ?? 0
            
            recurrenceDays = max(difference + 1, 1)
        } else {
            recurrenceDays = 7
        }
        errorMessage = nil
    }
    
    func cancelEditing() {
        resetForm()
    }
    
    func deleteTask(_ task: Task) -> Bool {
        context.delete(task)
        
        do {
            try context.save()
            
            if taskBeingEdited?.objectID == task.objectID {
                resetForm()
            }
            
            errorMessage = nil
            return true
        } catch {
            context.rollback()
            errorMessage = "Não foi possível apagar a tarefa: \(error.localizedDescription)"
            return false
        }
    }
    
    private func resetForm() {
        taskBeingEdited = nil
        title = ""
        description = ""
        selectedPet = nil
        date = Date()
        usesCustomDate = false
        isPriority = false
        isRecurring = false
        hasRecurrenceLimit = false
        recurrenceDays = 7
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
    
    func toggleTaskCompletion(_ task: Task) {
        guard task.managedObjectContext === context else {
            errorMessage = "A tarefa e a ViewModel estão usando contextos diferentes."
            return
        }
        
        let now = Date()
        
        if task.isComplete {
            task.isComplete = false
            task.completedAt = nil
            
        } else if task.isRecurring {
            
            
            let currentDate = task.date ?? now
            
            guard let nextDate = nextDailyDate(after: currentDate, relativeTo: now) else {
                errorMessage = "Não foi possível calcular a próxima data."
                return
            }
            
            if let endDate = task.recurrenceEndDate, nextDate > endDate {
                task.isComplete = true
                task.completedAt = now
                task.isRecurring = false
                task.recurrenceEndDate = nil
            } else {
                
                task.date = nextDate
                task.isComplete = false
                task.completedAt = nil
            }
            
        } else {
            
            task.isComplete = true
            task.completedAt = now
        }
        
        do {
            try context.save()
            errorMessage = nil
        } catch {
            context.rollback()
            errorMessage = "Não foi possível atualizar a tarefa: \(error.localizedDescription)"
        }
    }
    
    
    
}
