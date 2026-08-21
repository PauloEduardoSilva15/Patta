//
//  CoreDataVaccineRegistryRepository.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 21/08/26.
//

import Foundation
import CoreData

final class CoreDataVaccineRegistryRepository: VaccineRegistryRepositoryProtocol {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchAll(forPetId: UUID) throws -> [VaccineRegistryModel] {
        let request = VaccineRegistry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \VaccineRegistry.applicationDate, ascending: true)]
        return try context.fetch(request).compactMap(mapToModel)
    }
    
    func add(_ model: VaccineRegistryModel) throws {
        let vaccineRegistry = VaccineRegistry(context: context)
        try apply(model, to: vaccineRegistry)
        try save()
    }
    
    func update(_ model: VaccineRegistryModel) throws {
        guard let vaccineRegistry = try fetchManagedObject(id: model.id) else { return }
        try apply(model, to: vaccineRegistry)
        try save()
    }
    
    func delete(id: UUID) throws {
        guard let vaccineRegistry = try fetchManagedObject(id: id) else { return }
        context.delete(vaccineRegistry)
        try save()
    }
    
    private func apply(_ model: VaccineRegistryModel, to vaccineRegistry: VaccineRegistry) throws {
        vaccineRegistry.id = model.id
        vaccineRegistry.applicationDate = model.applicationDate
        vaccineRegistry.vaccine = try fetchVaccine(id: model.vaccine.id)
        vaccineRegistry.pet = try fetchPet(id: model.petId ?? UUID())
    }
    
    private func fetchManagedObject(id: UUID) throws -> VaccineRegistry? {
        let request = VaccineRegistry.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
    
    private func fetchVaccine(id: UUID) throws -> Vaccine? {
        let request = Vaccine.fetchRequest()
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
    
    private func mapToModel(_ vaccineRegistry: VaccineRegistry) throws -> VaccineRegistryModel? {
        guard let id = vaccineRegistry.id,
              let applicationDate = vaccineRegistry.applicationDate,
              let vaccine = vaccineRegistry.vaccine,
              let vaccineId = vaccine.id,
              let petId = vaccineRegistry.pet?.id else { return nil }
        
        return VaccineRegistryModel (
            id: id,
            applicationDate: applicationDate,
            vaccine: VaccineModel(id: vaccineId, title: vaccine.title ?? ""),
            petId: petId
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
