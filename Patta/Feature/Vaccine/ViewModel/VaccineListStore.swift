//
//  VaccineListStore.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 21/08/26.
//

import Foundation

@Observable
final class VaccineListStore {
    private(set) var vaccines: [VaccineModel] = []
    private let repository: VaccineRepositoryProtocol
    
    init(repository: VaccineRepositoryProtocol) {
        self.repository = repository
        refresh()
    }
    
    func refresh() {
        do {
            vaccines = try repository.fetchAll()
        } catch {
            print("Erro ao buscar pets \(error)")
        }
    }
    
    func add(_ vaccine: VaccineModel) throws {
        try repository.add(vaccine)
        refresh()
    }
    
    func update(_ vaccine: VaccineModel) throws {
        try repository.update(vaccine)
        refresh()
    }
    
    func delete(id: UUID) throws {
        try repository.delete(id: id)
        refresh()
    }
}
