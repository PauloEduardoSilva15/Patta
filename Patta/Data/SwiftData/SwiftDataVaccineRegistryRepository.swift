//
//  CoreDataVaccineRegistryRepository.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 24/08/26.
//

import Foundation
import SwiftData

enum VaccineRegistryRepositoryError: LocalizedError {
    case missingPetId
    case petNotFound(UUID)
    case vaccineNotFound(UUID)
    case registryNotFound(UUID)

    var errorDescription: String? {
        switch self {
        case .missingPetId:
            return "O registro não possui um Pet."

        case .petNotFound:
            return "O Pet do registro não foi encontrado."

        case .vaccineNotFound:
            return "A vacina selecionada não foi encontrada."

        case .registryNotFound:
            return "O registro de vacina não foi encontrado."
        }
    }
}

final class SwiftDataVaccineRegistryRepository: VaccineRegistryRepositoryProtocol {
    
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func fetchAll() throws -> [VaccineRegistryModel] {
        let descriptor = FetchDescriptor<VaccineRegistryModel>(sortBy: [SortDescriptor(\.applicationDate, order: .forward)])
        return try context.fetch(descriptor)
    }
    
    func add(_ model: VaccineRegistryModel) throws {
        context.insert(model)
        try save()
    }
    
    func update(_ model: VaccineRegistryModel) throws {
        context.insert(model)
        try save()
    }
    
    func delete(id: UUID) throws {
        let predicate = #Predicate<VaccineRegistryModel> { $0.id == id }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        if let vaccineRegistryToDelete = try context.fetch(descriptor).first {
            context.delete(vaccineRegistryToDelete)
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
