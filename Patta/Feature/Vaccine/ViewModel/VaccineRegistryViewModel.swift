//
//  VaccineRegistryViewModel.swift
//  Patta
//
//  Created by Pedro Canute on 17/08/26.
//

import CoreData
import Observation

@MainActor
@Observable
final class VaccineRegistryViewModel {
    
    var applicationDate = Date()
    var selectedVaccine: VaccineModel?
    var errorMessage: String?
    
    private var registryBeingEditedId: UUID?
    var activePetForSheet: PetModel?
    
    var isEditing: Bool {
        registryBeingEditedId != nil
    }
    
    var formTitle: String {
        isEditing ? "Editar Vacina" : "Adicionar Vacina"
    }
    
    private let store: VaccineRegistryListStore
    
    init(store: VaccineRegistryListStore) {
        self.store = store
    }
    
    func prepareNewRegistry() {
        applicationDate = Date()
        registryBeingEditedId = nil
        selectedVaccine = nil
        errorMessage = nil
    }
    
    func prepareForEditing(registry: VaccineRegistryModel) {
        guard let savedApplicationDate = registry.applicationDate else { return }
        
        applicationDate = savedApplicationDate
        selectedVaccine = registry.vaccine
        registryBeingEditedId = registry.id
        errorMessage = nil
    }
    
    func saveRegistry(petId: UUID) -> Bool {
        
        guard let selectedVaccine else {
            errorMessage = "Selecione uma vacina"
            return false
        }
        
        let model = VaccineRegistryModel (
            id: registryBeingEditedId ?? UUID(),
            applicationDate: applicationDate,
            vaccine: selectedVaccine,
            petId: petId
        )
        
        do {
            if registryBeingEditedId != nil {
                try store.update(model)
            } else {
                try store.add(model)
            }
            return true
        } catch {
            let nsError = error as NSError
            print("Erro: \(nsError), detalhes: \(nsError.userInfo)")
            errorMessage = "Não foi possível salvar o registro: \(error.localizedDescription)"
            return false
        }
        
        func deleteRegistry(id: UUID) {
            do {
                try store.delete(id: id)
                errorMessage = nil
                registryBeingEditedId = nil
            } catch {
                errorMessage = "Não foi possível excluir o registro: \(error.localizedDescription)"
            }
        }
        
        func cancelEditing() {
            prepareNewRegistry()
        }
    }
}
