//
//  VaccineRegistryListStore.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 21/08/26.
//

import Foundation

@Observable
final class VaccineRegistryListStore {
    private(set) var vaccineRegistries: [VaccineRegistryModel] = []
    private let repository: VaccineRegistryRepositoryProtocol
    private let petId: UUID?
    
    init(repository: VaccineRegistryRepositoryProtocol, petId: UUID = UUID()) {
        self.repository = repository
        self.petId = petId
        refresh()
    }
    
    func refresh() {
        do {
            vaccineRegistries = try repository.fetchAll(forPetId: petId ?? UUID())
        } catch {
            print("Erro ao buscar registros de vacina \(error)")
        }
    }
    
    func add(_ vaccineRegistry: VaccineRegistryModel) throws {
        try repository.add(vaccineRegistry)
        refresh()
    }
    
    func update(_ vaccineRegistry: VaccineRegistryModel) throws {
        try repository.update(vaccineRegistry)
        refresh()
    }
    
    func delete(id: UUID) throws {
        try repository.delete(id: id)
        refresh()
    }
}
