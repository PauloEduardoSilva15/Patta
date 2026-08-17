//
//  TaskViewModel.swift
//  Patta
//
//  Created by Pedro Canute on 17/08/26.
//

import Combine
import CoreData

@MainActor
@Observable
final class TaskViewModel {
    var title = ""
    var description = ""
    var errorMessage: String?
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func createTask() -> Bool {
        let treatedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !treatedTitle.isEmpty else {
            errorMessage = "Digite o título da tarefa"
            return false
        }
        
        let task = Task(context: context)
        
        task.id = UUID()
        task.title = treatedTitle
        task.desc = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            try context.save()

            print("Tarefa salva com sucesso")
            print("ID:", task.objectID)

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
    
    func deleteTask(_ task: Task) {
        context.delete(task)
        saveChanges()
    }
    
    func prepareNewTask() {
        clearForm()
        errorMessage = nil
    }
    
    func saveChanges() {
        do {
            try context.save()
            errorMessage = nil
        } catch {
            context.rollback()
            errorMessage = "Não foi possível salvar as alterações: \(error.localizedDescription)"
        }
    }
    
    func clearForm() {
        title = ""
        description = ""
    }
}
