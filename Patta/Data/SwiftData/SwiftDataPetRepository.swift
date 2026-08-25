//
//  SwiftDataPetRepository.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 24/08/26.
//

import Foundation
import SwiftData

final class SwiftDataPetRepository: PetRepositoryProtocol {
    
    let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func fetchAll() throws -> [PetModel] {
        let descriptor = FetchDescriptor<PetModel>(sortBy: [SortDescriptor(\.name, order: .forward)])
        return try context.fetch(descriptor)
    }
    
    func add(_ model: PetModel) throws {
        context.insert(model)
        try save()
    }
    
    func update(_ model: PetModel) throws {
        context.insert(model)
        try save()
    }
    
    func delete(id: UUID) throws {
        let predicate = #Predicate<PetModel> { $0.id == id }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        if let petToDelete = try context.fetch(descriptor).first {
            context.delete(petToDelete)
            try save()
        }
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
