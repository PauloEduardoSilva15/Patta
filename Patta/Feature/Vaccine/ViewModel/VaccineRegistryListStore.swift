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
        
        refresh()
    }
    
    func refresh(for petId: UUID) {
        refresh()
    }
    
    func refresh() {
        vaccineRegistries = []
        
        do {
            vaccineRegistries = try repository.fetchAll()
        } catch {
            print(
                "Erro ao buscar registros de vacina: \(error)"
            )
        }
    }
    
    func add(
        _ vaccineRegistry: VaccineRegistryModel
    ) throws {
        try repository.add(vaccineRegistry)
        
        refresh()
    }
    
    func update(
        _ vaccineRegistry: VaccineRegistryModel
    ) throws {
        try repository.update(vaccineRegistry)        
        refresh()
    }
    
    func delete(id: UUID) throws {
        try repository.delete(id: id)
        refresh()
    }
}
