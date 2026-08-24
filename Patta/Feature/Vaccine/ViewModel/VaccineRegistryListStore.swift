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
    private var petId: UUID?

    init(
        repository: VaccineRegistryRepositoryProtocol,
        petId: UUID? = nil
    ) {
        self.repository = repository
        self.petId = petId

        if petId != nil {
            refresh()
        }
    }

    func refresh(for petId: UUID) {
        self.petId = petId
        refresh()
    }

    func refresh() {
        guard let petId else {
            vaccineRegistries = []
            return
        }

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

        if let registryPetId = vaccineRegistry.petId {
            petId = registryPetId
        }

        refresh()
    }

    func update(
        _ vaccineRegistry: VaccineRegistryModel
    ) throws {
        try repository.update(vaccineRegistry)

        if let registryPetId = vaccineRegistry.petId {
            petId = registryPetId
        }

        refresh()
    }

    func delete(id: UUID) throws {
        try repository.delete(id: id)
        refresh()
    }
}
