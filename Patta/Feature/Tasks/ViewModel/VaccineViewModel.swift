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
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func createVaccine() -> Bool {
        let titleTreated = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !titleTreated.isEmpty else {
            errorMessage = "Por favor, forneça um nome para a vacina"
            return false
        }
        
        let vaccine = Vaccine(context: context)
        
        vaccine.title = titleTreated
        vaccine.id = UUID()
        
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
        saveChanges()
    }
    
    func clearForm() {
        title = ""
    }
    
    func saveChanges() {
        do {
            try context.save()
            errorMessage = nil
        } catch {
            context.rollback()
            errorMessage = "Não foi possível salvar as alterações: \(error.localizedDescription)"
        }
    }
    
    func prepareNewVaccine() {
        clearForm()
        errorMessage = nil
    }
}
