//
//  PetListStore.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 20/08/26.
//

import Foundation

@Observable
final class PetListStore {
    private(set) var pets: [PetModel] = []
    private let repository: PetRepositoryProtocol
    
    init(repository: PetRepositoryProtocol) {
        self.repository = repository
        refresh()
    }
    
    func refresh() {
        do {
            pets = try repository.fetchAll()
        } catch {
            print("Erro ao buscar pets \(error)")
        }
    }
    
    func add(_ pet: PetModel) throws {
        try repository.add(pet)
        refresh()
    }
    
    func update(_ pet: PetModel) throws {
        try repository.update(pet)
        refresh()
    }
    
    func delete(id: UUID) throws {
        try repository.delete(id: id)
        refresh()
    }
}
