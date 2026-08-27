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
    var isSaving = false
    var date = Date()
    var usesCustomDate = false
    var selectedPet: PetModel?
    var isPriority = false

    var isReminderEnabled = false
    var reminderDate = Date().addingTimeInterval(60 * 60)

    var isRecurring = false
    var hasRecurrenceLimit = false
    var recurrenceDays = 7
    
    private(set) var taskBeingEdited: TaskModel?

    private let store: TaskListStore
    private let notificationService: LocalNotificationService
    
    var isEditing: Bool {
        taskBeingEdited != nil
    }
    
    var formTitle: String {
        isEditing ? "Editar Tarefa" : "Nova Tarefa"
    }
    
    init(store: TaskListStore, notificationService: LocalNotificationService) {
        self.store = store
        self.notificationService = notificationService
    }
    
    func loadTasks() {
        do {
            try store.refresh()
            errorMessage = nil
        } catch {
            errorMessage = "Falha ao carregar as tarefas."
        }
    }
    
    func saveTask() async -> Bool {
        guard !isSaving else {
            return false
        }
        
        isSaving = true
        
        defer {
            isSaving = false
        }
        
        let treatedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !treatedTitle.isEmpty else {
            errorMessage = "Digite o título da tarefa."
            return false
        }
        
        let now = Date()
        
        let shouldSaveReminder = isPriority && isReminderEnabled
        
        if shouldSaveReminder && reminderDate <= now {
            errorMessage = "Escolha uma data futura para o alerta."
            return false
        }
        
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
            
            guard let calculatedEndDate =
                    Calendar.current.date(
                        byAdding: .day,
                        value: daysToAdd,
                        to: taskDate
                    )
            else {
                errorMessage = "Falha ao calcular a data de término."
                return false
            }
            
            recurrenceEndDate = calculatedEndDate
        } else {
            recurrenceEndDate = nil
        }
        
        do {
            let savedTask: TaskModel
            
            if let taskBeingEdited {
                taskBeingEdited.title = treatedTitle
                
                taskBeingEdited.taskDescription = taskDescription.trimmingCharacters(in: .whitespacesAndNewlines)
                
                taskBeingEdited.date = taskDate
                
                taskBeingEdited.usesCustomDate = usesCustomDate
                
                taskBeingEdited.isPriority = isPriority
                
                taskBeingEdited.isReminderEnabled = shouldSaveReminder
                
                taskBeingEdited.reminderDate = shouldSaveReminder ? reminderDate : nil
                
                taskBeingEdited.isRecurring = isRecurring
                
                taskBeingEdited.recurrenceEndDate = recurrenceEndDate
                
                taskBeingEdited.pet = selectedPet
                
                try store.update(taskBeingEdited)
                
                savedTask = taskBeingEdited
            } else {
                let newTask = TaskModel(
                    id: UUID(),
                    title: treatedTitle,
                    taskDescription:
                        taskDescription.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ),
                    createdAt: createdAt,
                    date: taskDate,
                    completedAt: nil,
                    usesCustomDate: usesCustomDate,
                    isPriority: isPriority,
                    isReminderEnabled:
                        shouldSaveReminder,
                    reminderDate:
                        shouldSaveReminder
                        ? reminderDate
                        : nil,
                    isRecurring: isRecurring,
                    recurrenceEndDate:
                        recurrenceEndDate,
                    isCompleted: false,
                    pet: selectedPet
                )
                
                try store.add(newTask)
                
                savedTask = newTask
            }
            
            if shouldSaveReminder {
                do {
                    try await notificationService
                        .scheduleReminder(
                            taskID: savedTask.id,
                            taskTitle: savedTask.title,
                            reminderDate: reminderDate
                        )
                } catch {
                    savedTask.isReminderEnabled = false
                    savedTask.reminderDate = nil
                    
                    try? store.update(savedTask)
                    
                    taskBeingEdited = savedTask
                    
                    errorMessage =
                        """
                        A tarefa foi salva, mas não foi \
                        possível criar o alerta: \
                        \(error.localizedDescription)
                        """
                    
                    return false
                }
            } else {
                notificationService.cancelReminder(
                    for: savedTask.id
                )
            }
            
            resetForm()
            return true
            
        } catch {
            errorMessage =
                """
                Não foi possível salvar a tarefa: \
                \(error.localizedDescription)
                """
            
            return false
        }
    }
    
    func prepareNewTask(for selectedDate: Date) {
        resetForm()

        let calendar = Calendar.current
        let currentTime = calendar.dateComponents([.hour, .minute], from: Date())

        date = calendar.date(bySettingHour: currentTime.hour ?? 9, minute: currentTime.minute ?? 0,second: 0, of: selectedDate) ?? selectedDate

        usesCustomDate = true
    }
    
    func prepareToEdit(_ task: TaskModel) {
        
        taskBeingEdited = task
        title = task.title
        taskDescription = task.taskDescription
        date = task.date ?? Date()
        usesCustomDate = task.usesCustomDate ?? false
        selectedPet = task.pet
        isPriority = task.isPriority

        isReminderEnabled = task.isReminderEnabled
        reminderDate = task.reminderDate ?? Date().addingTimeInterval(60 * 60)

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
    
    func handlePriorityChange() {
        if !isPriority {
            isReminderEnabled = false
        }
    }
    
    func handleReminderChange() async {
        guard isReminderEnabled else {
            return
        }
        
        guard isPriority else {
            isReminderEnabled = false
            return
        }
        
        do {
            let authorization =
                await notificationService.authorizationState()
            
            switch authorization {
            case .authorized:
                errorMessage = nil
                
            case .notDetermined:
                let permissionWasGranted =
                    try await notificationService
                        .requestPermission()
                
                if permissionWasGranted {
                    errorMessage = nil
                } else {
                    isReminderEnabled = false
                    errorMessage =
                        """
                        As notificações não foram permitidas. \
                        Você pode ativá-las nos Ajustes do iPhone.
                        """
                }
                
            case .denied:
                isReminderEnabled = false
                errorMessage =
                    """
                    As notificações do Patta estão desativadas. \
                    Ative-as nos Ajustes do iPhone para criar alertas.
                    """
            }
        } catch {
            isReminderEnabled = false
            errorMessage =
                """
                Não foi possível solicitar a permissão \
                para notificações.
                """
        }
    }
    
    func cancelEditing() {
        resetForm()
    }
    
    func deleteTask(_ task: TaskModel) -> Bool {
        
        do {
            try store.delete(id: task.id)

            notificationService.cancelReminder(for: task.id)

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

        isReminderEnabled = false
        reminderDate = Date().addingTimeInterval(60 * 60)

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
                
                updatedTask.isReminderEnabled = false
                updatedTask.reminderDate = nil
                
            } else {
                if updatedTask.isReminderEnabled {
                    if let currentReminderDate =
                        updatedTask.reminderDate {
                        
                        let timeShift =
                            nextDate.timeIntervalSince(
                                currentDate
                            )
                        
                        let nextReminderDate =
                            currentReminderDate
                                .addingTimeInterval(timeShift)
                        
                        if nextReminderDate > now {
                            updatedTask.reminderDate =
                                nextReminderDate
                        } else {
                            updatedTask.isReminderEnabled =
                                false
                            
                            updatedTask.reminderDate = nil
                        }
                    } else {
                        updatedTask.isReminderEnabled = false
                    }
                }
                
                updatedTask.date = nextDate
                updatedTask.isCompleted = false
                updatedTask.completedAt = nil
            }
            
        } else {
            updatedTask.isCompleted = true
            updatedTask.completedAt = now
            
            updatedTask.isReminderEnabled = false
            updatedTask.reminderDate = nil
        }
        
        do {
            try store.update(updatedTask)

            if updatedTask.isCompleted {
                notificationService.cancelReminder(
                    for: updatedTask.id
                )
                
            } else if updatedTask.isRecurring,
                      updatedTask.isReminderEnabled,
                      let nextReminderDate =
                        updatedTask.reminderDate {
                
                Task { @MainActor in
                    do {
                        try await notificationService
                            .scheduleReminder(
                                taskID: updatedTask.id,
                                taskTitle: updatedTask.title,
                                reminderDate: nextReminderDate
                            )
                        
                    } catch {
                        updatedTask.isReminderEnabled = false
                        updatedTask.reminderDate = nil
                        
                        try? store.update(updatedTask)
                        
                        notificationService.cancelReminder(
                            for: updatedTask.id
                        )
                        
                        errorMessage =
                            """
                            A tarefa foi reagendada, mas não foi \
                            possível criar o próximo alerta.
                            """
                    }
                }
                
            } else {
                notificationService.cancelReminder(
                    for: updatedTask.id
                )
            }

            errorMessage = nil
        } catch {
            errorMessage = "Não foi possível atualizar a tarefa. Por favor, tente novamente."
        }
    }
    
}
