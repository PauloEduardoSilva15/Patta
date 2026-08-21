//
//  CoreDataPetRepository.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 20/08/26.
//

import Foundation
import CoreData

final class CoreDataPetRepository: PetRepositoryProtocol {
    
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchAll() throws -> [PetModel] {
        let request = Pet.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Pet.name, ascending: true)]
        return try context.fetch(request).map(mapToModel)
    }
    
    func add(_ model: PetModel) throws {
        let pet = Pet(context: context)
        pet.id = model.id
        apply(model, to: pet)
        try save()
    }
    
    func update(_ model: PetModel) throws {
        guard let pet = try fetchManagedObject(id: model.id) else { return }
        apply(model, to: pet)
        try save()
    }
    
    func delete(id: UUID) throws {
        guard let pet = try fetchManagedObject(id: id) else { return }
        context.delete(pet)
        try save()
    }
    
    private func fetchManagedObject(id: UUID) throws -> Pet? {
        let request = Pet.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
    
    private func apply(_ model: PetModel, to pet: Pet) {
        pet.name = model.name
        pet.weight = model.weight.map { NSDecimalNumber(floatLiteral: $0) }
        pet.breed = model.breed
        pet.birthdate = model.birthdate
        pet.med_cond = model.medicalConditions
        pet.image = model.image
    }
    
    func mapToModel(_ pet: Pet) -> PetModel {
        PetModel(
            id: pet.id ?? UUID(),
            name: pet.name ?? "",
            weight: pet.weight?.doubleValue,
            breed: pet.breed ?? "",
            birthdate: pet.birthdate ?? Date(),
            medicalConditions: pet.med_cond ?? "",
            image: pet.image
        )
    }
    
    private func save() throws {
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}
