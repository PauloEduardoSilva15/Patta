//
//  VacinaViewModel.swift
//  Patta
//
//  Created by Pedro Canute on 17/08/26.
//

import CoreData
import Combine

@MainActor
@Observable
final class VacineViewModel {
    var title = ""
    var errorMessage: String?
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func criarVacina() -> Bool {
        let titleTreated = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !titleTreated.isEmpty else {
            errorMessage = "Por favor, forneça um nome para a vacina"
            return false
        }
        
        let vacine = Vacina(context: context)
        
        vacine.title = titleTreated
        vacine.id = UUID()
        
        do {
            try context.save()
            
            limparFormulario()
            errorMessage = nil
            return true
        } catch {
            context.rollback()
            errorMessage = "Não foi possível salvar a vacina: \(error.localizedDescription)"
            return false
        }
    }
    
    func apagarVacina(_ vacina: Vacina) {
        context.delete(vacina)
        salvarAlteracoes()
    }
    
    func limparFormulario() {
        title = ""
    }
    
    func salvarAlteracoes() {
        do {
            try context.save()
            errorMessage = nil
        } catch {
            context.rollback()
            errorMessage = "Não foi possível salvar as alterações: \(error.localizedDescription)"
        }
    }
    
    func prepararNovaVacina() {
        limparFormulario()
        errorMessage = nil
    }
}
