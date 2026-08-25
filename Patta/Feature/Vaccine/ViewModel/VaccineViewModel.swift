//
//  VaccineViewModel.swift
//  Patta
//
//  Created by Pedro Canute on 17/08/26.
//

import Foundation
import Combine

@MainActor
@Observable
final class VaccineViewModel {
    var title = ""
    var errorMessage: String?
    
    var vaccineBeingEdited: VaccineModel?
    
    private let store: VaccineListStore
    
    var isEditing: Bool {
        vaccineBeingEdited != nil
    }
    
    var formTitle: String {
        isEditing ? "Editar vacina" : "Nova vacina"
    }
    
    init(store: VaccineListStore) {
        self.store = store
    }
    
    func createVaccine() -> Bool {
        let titleTreated = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !titleTreated.isEmpty else {
            errorMessage = "Por favor, forneça um nome para a vacina"
            return false
        }
        
        do {
            if let vaccineBeingEdited {
                vaccineBeingEdited.title = title
                try store.update(vaccineBeingEdited)
            } else {
                let newVaccine = VaccineModel (
                    id: UUID(),
                    title: title
                )
                try store.add(newVaccine)
            }
            clearForm()
            errorMessage = nil
            return true
        } catch {
            errorMessage = "Não foi possível salvar a vacina: \(error.localizedDescription)"
            return false
        }
    }
    
    func deleteVaccine(id: UUID) {
        do {
            try store.delete(id: id)
            
            clearForm()
            errorMessage = nil
        } catch {
            errorMessage = "Não foi possível excluir a vacina: \(error.localizedDescription)"
        }
    }
    
    func clearForm() {
        vaccineBeingEdited = nil
        title = ""
    }
    
    func prepareNewVaccine() {
        vaccineBeingEdited = nil
        title = ""
        errorMessage = nil
    }
    
    func prepareToEdit(_ vaccine: VaccineModel) {
        vaccineBeingEdited = vaccine
        title = vaccine.title
        errorMessage = nil
        
    }
    
    func cancelEditing() {
        clearForm()
        errorMessage = nil
    }
}
