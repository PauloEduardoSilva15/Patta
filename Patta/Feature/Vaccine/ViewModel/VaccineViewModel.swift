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
    
    var vaccineBeingEditedId: UUID?
    
    private let store: VaccineListStore
    
    var isEditing: Bool {
        vaccineBeingEditedId != nil
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
        
        let model = VaccineModel (
            id: vaccineBeingEditedId ?? UUID(),
            title: title
        )
        
        do {
            if vaccineBeingEditedId != nil {
                 try store.update(model)
            } else {
                try store.add(model)
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
            
            if vaccineBeingEditedId == id {
                clearForm()
            }
            errorMessage = nil
        } catch {
            errorMessage = "Não foi possível excluir a vacina: \(error.localizedDescription)"
        }
    }
    
    func clearForm() {
        vaccineBeingEditedId = nil
        title = ""
    }
    
    func prepareNewVaccine() {
        vaccineBeingEditedId = nil
        title = ""
        errorMessage = nil
    }
    
    func prepareToEdit(_ vaccine: VaccineModel) {
        vaccineBeingEditedId = vaccine.id
        title = vaccine.title
        errorMessage = nil
        
    }
    
    func cancelEditing() {
        clearForm()
        errorMessage = nil
    }
}
