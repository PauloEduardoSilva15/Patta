//
//  CoreDataTaskRepository.swift
//  Patta
//
//  Created by Pedro Canute on 22/08/26.
//

import SwiftData
import Foundation

enum TaskRepositoryError: LocalizedError {
    case taskNotFound(UUID)
    case petNotFound(UUID)
    case missingPetRelationship
    case invalidStoredTask
    case invalidStoredPet
    
    var errorDescription: String? {
        switch self {
        case .taskNotFound(let id):
            return "A tarefa com id: \(id) não foi encontrada"
        case .petNotFound(let id):
            return "Pet com id: \(id) não encontrado"
        case .missingPetRelationship:
            return "A tarefa não possui relacionamento com pet associado"
        case .invalidStoredTask:
            return "Uma tarefa possui dados inválidos"
        case .invalidStoredPet:
            return "O pet relacionado possui dados inválidos"
        }
    }
}

@MainActor
final class SwiftDataTaskRepository: TaskRepositoryProtocol {
    
    private let context: ModelContext
    
    init(context: ModelContext){
        self.context = context
    }
    
    func fetchAll() throws -> [TaskModel] {
        let descriptor = FetchDescriptor<TaskModel>(sortBy: [SortDescriptor(\.createdAt, order: .forward)])
        return try context.fetch(descriptor)
    }
    
    func add(_ model: TaskModel) throws {
       context.insert(model)
        try save()
    }
    
    func update(_ model: TaskModel) throws {
        context.insert(model)
        try save()
    }
    
    func delete(id: UUID) throws {
        let predicate = #Predicate<TaskModel>{ $0.id == id}
        let descriptor = FetchDescriptor<TaskModel>(predicate: predicate)
        
        
        if let task = try context.fetch(descriptor).first {
            context.delete(task)
            try save()
        }
    }
    
    
    private func save() throws {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}
