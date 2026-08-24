//
//  SwiftDataVaccineRepository.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 24/08/26.
//

import Foundation
import SwiftData

final class SwiftDataVaccineRepository: VaccineRepositoryProtocol {
    
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func fetchAll() throws -> [VaccineModel] {
        let descriptor = FetchDescriptor<VaccineModel>(sortBy: [SortDescriptor(\.title, order: .forward)])
        return try context.fetch(descriptor)
    }
    
    func add(_ model: VaccineModel) throws {
        context.insert(model)
        try save()
    }
    
    func update(_ model: VaccineModel) throws {
        try save()
    }
    
    func delete(id: UUID) throws {
        let predicate = #Predicate<VaccineModel> { $0.id == id }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        if let vaccineToDelete = try context.fetch(descriptor).first {
            context.delete(vaccineToDelete)
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
