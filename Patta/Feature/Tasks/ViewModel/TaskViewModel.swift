//
//  TaskViewModel.swift
//  Patta
//
//  Created by Pedro Canute on 17/08/26.
//
import Foundation
import Observation

@MainActor
@Observable
final class TaskViewModel {
    var title = ""
    var taskDescription = ""
    var errorMessage: String?
    var date = Date()
    var usesCustomDate = false
    var selectedPet: PetModel?
    var isPriority = false
    var isRecurring = false
    var hasRecurrenceLimit = false
    var recurrenceDays = 7
    
    private(set) var taskBeingEdited: TaskModel?
    private let store: TaskListStore
    
    var isEditing: Bool {
        taskBeingEdited != nil
    }
    
    var formTitle: String {
        isEditing ? "Editar Tarefa" : "Nova Tarefa"
    }
    
    init(store: TaskListStore) {
        self.store = store
    }
    
    func loadTasks() {
        do {
            try store.refresh()
            errorMessage = nil
        } catch {
            errorMessage = "Falha ao carregar as tarefas."
        }
    }
    
    func saveTask() -> Bool {
        let treatedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !treatedTitle.isEmpty else {
            errorMessage = "Digite o título da tarefa."
            return false
        }
        let now = Date()
        let createdAt = taskBeingEdited?.createdAt ?? now
        let taskDate: Date
        
        if usesCustomDate {
            taskDate = date
        } else {
            taskDate = createdAt
        }
        
        let recurrenceEndDate: Date?
        
        if isRecurring && hasRecurrenceLimit {
            let daysToAdd = max(recurrenceDays - 1, 0)
            
            guard let calculatedEndDate = Calendar.current.date(byAdding: .day, value: daysToAdd, to: taskDate) else {
                errorMessage = "Falha ao calcular a data de término."
                return false
            }
            recurrenceEndDate = calculatedEndDate
            
        } else {
            recurrenceEndDate = nil
        }
        
        do {
            if let taskBeingEdited {
                taskBeingEdited.title = treatedTitle
                taskBeingEdited.taskDescription = taskDescription.trimmingCharacters(in: .whitespacesAndNewlines)
                taskBeingEdited.date = taskDate
                taskBeingEdited.usesCustomDate = usesCustomDate
                taskBeingEdited.isPriority = isPriority
                taskBeingEdited.isRecurring = isRecurring
                taskBeingEdited.recurrenceEndDate = recurrenceEndDate
                taskBeingEdited.pet = selectedPet
                try store.update(taskBeingEdited)
            } else {
                let newTask = TaskModel(
                    id: taskBeingEdited?.id ?? UUID(),
                    title: treatedTitle,
                    taskDescription: taskDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                    createdAt: createdAt,
                    date: taskDate,
                    completedAt:taskBeingEdited?.completedAt,
                    usesCustomDate: usesCustomDate,
                    isPriority: isPriority,
                    isRecurring: isRecurring,
                    recurrenceEndDate: recurrenceEndDate,
                    isCompleted: taskBeingEdited?.isCompleted ?? false,
                    pet: selectedPet
                )
                try store.add(newTask)
            }
            resetForm()
            
            return true
        } catch {
            errorMessage = "Não foi possivel salvar a tarefa."
            return false
        }
    }
    
    func prepareNewTask() {
        resetForm()
    }
    
    func prepareToEdit(_ task: TaskModel) {
        
        taskBeingEdited = task
        title = task.title
        taskDescription = task.taskDescription
        date = task.date ?? Date()
        usesCustomDate = task.usesCustomDate ?? false
        selectedPet = task.pet
        isPriority = task.isPriority
        isRecurring = task.isRecurring
        hasRecurrenceLimit = task.recurrenceEndDate != nil
        
        if let startDate = task.date,
           let endDate = task.recurrenceEndDate {
            
            let calendar = Calendar.current
            
            let normalizedStartDate = calendar.startOfDay(for: startDate)
            let normalizedEndDate = calendar.startOfDay(for: endDate)
            
            let difference = calendar.dateComponents([.day], from: normalizedStartDate, to: normalizedEndDate).day ?? 0
            
            recurrenceDays = max(difference + 1, 1)
        } else {
            recurrenceDays = 7
        }
        errorMessage = nil
    }
    
    func cancelEditing() {
        resetForm()
    }
    
    func deleteTask(_ task: TaskModel) -> Bool {
        
        do {
            try store.delete(id: task.id)
            
            if taskBeingEdited?.id == task.id {
                resetForm()
            } else {
                errorMessage = nil
            }
            
            return true
        } catch {
            errorMessage = "Não foi possível apagar a tarefa: \(error.localizedDescription)"
            return false
        }
    }
    
    private func resetForm() {
        taskBeingEdited = nil
        title = ""
        taskDescription = ""
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
    
    func toggleTaskCompletion(_ task: TaskModel) {
       
        
        let updatedTask = task
        
        let now = Date()
        
        if updatedTask.isCompleted {
            updatedTask.isCompleted = false
            updatedTask.completedAt = nil
        } else if updatedTask.isRecurring {
            let currentDate = updatedTask.date ?? now
            
            guard let nextDate = nextDailyDate(after: currentDate, relativeTo: now) else {
                errorMessage = "Não foi possível calcular a próxima data."
                return
            }
            
            if let endDate = updatedTask.recurrenceEndDate, nextDate > endDate {
                updatedTask.isCompleted = true
                updatedTask.completedAt = now
                updatedTask.isRecurring = false
                updatedTask.recurrenceEndDate = nil
                
            } else {
                updatedTask.date = nextDate
                updatedTask.isCompleted = false
                updatedTask.completedAt = nil
            }
            
        } else {
            updatedTask.isCompleted = true
            updatedTask.completedAt = now
        }
        
        do {
            try store.update(updatedTask)
            errorMessage = nil
        } catch {
            errorMessage = "Não foi possível atualizar a tarefa. Por favor, tente novamente."
        }
    }
    
}
