//
//  VaccineRegistryViewModel.swift
//  Patta
//
//  Created by Pedro Canute on 17/08/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class VaccineRegistryViewModel {

    var applicationDate = Date()
    var selectedVaccine: VaccineModel?
    var errorMessage: String?

    private var registryBeingEdited: VaccineRegistryModel?

    var activePetForSheet: PetModel?

    var isEditing: Bool {
        registryBeingEdited != nil
    }

    var formTitle: String {
        isEditing ? "Editar Vacina" : "Adicionar Vacina"
    }

    private let store: VaccineRegistryListStore

    init(store: VaccineRegistryListStore) {
        self.store = store
    }

    func prepareNewRegistry() {
        resetForm()
    }

    func prepareForEditing(
        registry: VaccineRegistryModel
    ) {
        registryBeingEdited = registry
        applicationDate = registry.applicationDate ?? Date()
        selectedVaccine = registry.vaccine
        errorMessage = nil
    }

    func saveRegistry(pet: PetModel) -> Bool {
        guard let selectedVaccine else {
            errorMessage = "Selecione uma vacina"
            return false
        }
        
        do {
            if let registryBeingEdited {
                registryBeingEdited.applicationDate = applicationDate
                registryBeingEdited.vaccine = selectedVaccine
                registryBeingEdited.pet = pet
                try store.update(registryBeingEdited)
            } else {
                let newRegistry = VaccineRegistryModel(
                    id: UUID(),
                    applicationDate: applicationDate,
                    vaccine: selectedVaccine,
                    pet: pet
                )
                try store.add(newRegistry)
            }
            
            resetForm()
            return true
        } catch {
            errorMessage = """
            Não foi possível salvar o registro: \
            \(error.localizedDescription)
            """

            return false
        }
    }

    func deleteRegistry(id: UUID) -> Bool {
        do {
            try store.delete(id: id)
            resetForm()
            return true
        } catch {
            errorMessage = """
            Não foi possível excluir o registro: \
            \(error.localizedDescription)
            """

            return false
        }
    }

    func cancelEditing() {
        resetForm()
    }

    private func resetForm() {
        registryBeingEdited = nil
        applicationDate = Date()
        selectedVaccine = nil
        errorMessage = nil
    }
}
