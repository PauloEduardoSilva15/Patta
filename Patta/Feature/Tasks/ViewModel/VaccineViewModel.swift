//
//  VaccineViewModel.swift
//  Patta
//
//  Created by Pedro Canute on 17/08/26.
//

import CoreData
import Combine

@MainActor
@Observable
final class VaccineViewModel {
    var title = ""
    var errorMessage: String?
    
    var vaccineBeingEdited: Vaccine?
    
    private let context: NSManagedObjectContext
    
    var isEditing: Bool {
        vaccineBeingEdited != nil
    }
    
    var formTitle: String {
        isEditing ? "Editar vacina" : "Nova vacina"
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func createVaccine() -> Bool {
        let titleTreated = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !titleTreated.isEmpty else {
            errorMessage = "Por favor, forneça um nome para a vacina"
            return false
        }
        
        let vaccine: Vaccine
        
        if let vaccineBeingEdited {
            vaccine = vaccineBeingEdited
        } else {
            vaccine = Vaccine(context: context)
            vaccine.id = UUID()
        }
        vaccine.title = titleTreated
        
        do {
            try context.save()
            
            clearForm()
            errorMessage = nil
            return true
        } catch {
            context.rollback()
            errorMessage = "Não foi possível salvar a vacina: \(error.localizedDescription)"
            return false
        }
    }
    
    func deleteVaccine(_ vaccine: Vaccine) {
        context.delete(vaccine)
        do {
            try context.save()
            
            if vaccineBeingEdited == vaccine {
                clearForm()
            }
            errorMessage = nil
        } catch {
            context.rollback()
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
    
    func prepareToEdit(_ vaccine: Vaccine) {
        vaccineBeingEdited = vaccine
        title = vaccine.title ?? "Sem título"
        errorMessage = nil
        
    }
    
    func cancelEditing() {
        clearForm()
        errorMessage = nil
    }
}
