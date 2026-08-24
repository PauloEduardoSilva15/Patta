//
//  CoreDataVaccineRepository.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 21/08/26.
//

import Foundation
import CoreData

final class CoreDataVaccineRepository: VaccineRepositoryProtocol {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchAll() throws -> [VaccineModel] {
        let request = Vaccine.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Vaccine.title, ascending: true)]
        return try context.fetch(request).compactMap(mapToModel)
    }
    
    func add(_ model: VaccineModel) throws {
        let vaccine = Vaccine(context: context)
        vaccine.id = model.id
        vaccine.title = model.title
        try save()
    }
    
    func update(_ model: VaccineModel) throws {
        guard let vaccine = try fetchManagedObject(id: model.id) else { return }
        vaccine.title = model.title
        try save()
    }
    
    func delete(id: UUID) throws {
        guard let vaccine = try fetchManagedObject(id: id) else { return }
        context.delete(vaccine)
        try save()
    }
    
    private func mapToModel(_ vaccine: Vaccine) -> VaccineModel? {
        guard let id = vaccine.id else { return nil }
        return VaccineModel(id: id, title: vaccine.title ?? "")
    }
    
    private func fetchManagedObject(id: UUID) throws -> Vaccine? {
        let request = Vaccine.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
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
