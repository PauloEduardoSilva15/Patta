//
//  CoreDataTaskRepository.swift
//  Patta
//
//  Created by Pedro Canute on 22/08/26.
//

import CoreData
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
final class CoreDataTaskRepository: TaskRepositoryProtocol {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext){
        self.context = context
    }
    
    func fetchAll() throws -> [TaskModel] {
        let request = Task.fetchRequest()
        
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Task.date, ascending: true)
        ]
        
        let storedTasks = try context.fetch(request)
        return try storedTasks.map(mapToModel)
    }
    
    func add(_ model: TaskModel) throws {
        let pet = try resolvePet(for: model)
        
        let task = Task(context: context)
        
        apply(model, to: task, pet: pet)
        try save()
    }
    
    func update(_ model: TaskModel) throws {
        guard let task = try fetchManagedObject(id: model.id) else {
            throw TaskRepositoryError.taskNotFound(model.id)
        }
        
        let pet = try resolvePet(for: model)
        
        apply(model, to: task, pet: pet)
        try save()
    }
    
    func delete(id: UUID) throws {
        guard let task = try fetchManagedObject(id: id) else {
            throw TaskRepositoryError.taskNotFound(id)
        }
        
        context.delete(task)
        
        try save()
    }
    
    private func fetchManagedObject(id: UUID) throws -> Task? {
        let request = Task.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        return try context.fetch(request).first
    }
    
    private func fetchPet(id: UUID) throws -> Pet? {
        let request = Pet.fetchRequest()
        
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        return try context.fetch(request).first
    }
    
    private func resolvePet(for model: TaskModel) throws -> Pet? {
        guard let petModel = model.pet else {
            return nil
        }
        
        guard let pet = try fetchPet(id: petModel.id) else {
            throw TaskRepositoryError.petNotFound(petModel.id)
        }
        
        return pet
    }
    
    private func apply(_ model: TaskModel, to task: Task, pet: Pet?) {
           task.id = model.id
           task.title = model.title
           task.desc = model.description

           task.createdAt = model.createdAt
           task.date = model.date
           task.completedAt = model.completedAt

           task.usesCustomDate = model.usesCustomDate ?? false
           task.isPriority = model.isPriority
           task.isRecurring = model.isRecurring
           task.recurrenceEndDate =
               model.recurrenceEndDate
           task.isComplete = model.isCompleted

           task.appliesToAllPets = model.appliesToAllPets

           task.pet = pet
       }
    
    private func mapToModel(_ task: Task) throws -> TaskModel {
        guard let id = task.id, let title = task.title, let createdAt = task.createdAt else {
            throw TaskRepositoryError.invalidStoredTask
        }
        
        let petModel: PetModel?
        
        if task.appliesToAllPets {
            petModel = nil
        } else {
            guard let pet = task.pet else {
                throw TaskRepositoryError.missingPetRelationship
            }
            petModel = try mapToPetModel(pet)
        }
        
        return TaskModel(
            id: id,
            title: title,
            description: task.desc ?? "",
            createdAt: createdAt,
            date: task.date,
            completedAt: task.completedAt,
            usesCustomDate: task.usesCustomDate,
            isPriority: task.isPriority,
            isRecurring: task.isRecurring,
            recurrenceEndDate: task.recurrenceEndDate,
            isCompleted: task.isComplete,
            pet: petModel
        )
    }
    
    private func mapToPetModel(_ pet: Pet) throws -> PetModel {
        guard let id = pet.id, let name = pet.name else {
            throw TaskRepositoryError.invalidStoredPet
        }
        
        return PetModel(
            id: id,
            name: name,
            weight: pet.weight?.doubleValue,
            breed: pet.breed,
            birthdate: pet.birthdate,
            medicalConditions: pet.med_cond,
            image: pet.image,
            color: PetColorPalette
                .normalizedAssetName(pet.color)
        )
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
