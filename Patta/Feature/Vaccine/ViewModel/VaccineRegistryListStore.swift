//
//  VaccineRegistryListStore.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 21/08/26.
//

import Foundation
import Observation

@Observable
final class VaccineRegistryListStore {
    
    private(set) var vaccineRegistries: [VaccineRegistryModel] = []
    
    private let repository: VaccineRegistryRepositoryProtocol
    
    init(
        repository: VaccineRegistryRepositoryProtocol
    ) {
        self.repository = repository
    }
    
    func refresh(for petId: UUID) {
        vaccineRegistries = []

        do {
            let all = try repository.fetchAll()
            vaccineRegistries = all.filter { $0.pet.id == petId }
        } catch {
            print("Erro ao buscar registros de vacina: \(error)")
        }
    }
    
    func add(
        _ vaccineRegistry: VaccineRegistryModel
    ) throws {
        try repository.add(vaccineRegistry)
        
        refresh(for: vaccineRegistry.pet.id)
    }
    
    func update(
        _ vaccineRegistry: VaccineRegistryModel
    ) throws {
        try repository.update(vaccineRegistry)        
        refresh(for: vaccineRegistry.pet.id)
    }
    
    func delete(id: UUID) throws {
        let petId = vaccineRegistries.first { $0.id == id }?.pet.id
        try repository.delete(id: id)
        if let petId {
            refresh(for: petId)
        }
    }
}
