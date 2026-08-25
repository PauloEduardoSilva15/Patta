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
    private var petId: UUID
    
    init(
        repository: VaccineRegistryRepositoryProtocol,
        petId: UUID
    ) {
        self.repository = repository
        self.petId = petId
        
        refresh()
    }
    
    func refresh(for petId: UUID) {
        self.petId = petId
        refresh()
    }
    
    func refresh() {
        vaccineRegistries = []
        
        do {
            vaccineRegistries = try repository.fetchAll(
                forPetId: petId
            )
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
        
        petId = vaccineRegistry.pet.id
        
        refresh()
    }
    
    func update(
        _ vaccineRegistry: VaccineRegistryModel
    ) throws {
        try repository.update(vaccineRegistry)
        
        petId = vaccineRegistry.pet.id
        
        refresh()
    }
    
    func delete(id: UUID) throws {
        try repository.delete(id: id)
        refresh()
    }
}
