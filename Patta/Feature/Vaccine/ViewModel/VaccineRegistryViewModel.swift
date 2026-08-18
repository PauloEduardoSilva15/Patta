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
    var registryBeingEdited: VaccineRegistry?
    var selectedVaccine: Vaccine?
    var errorMessage: String?
    
    var isEditing: Bool {
        registryBeingEdited != nil
    }
    
    var formTitle: String {
        isEditing ? "Editar Vacina" : "Adicionar Vacina"
    }
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func prepareNewRegistry() {
        applicationDate = Date()
        registryBeingEdited = nil
        selectedVaccine = nil
        errorMessage = nil
    }
    
    func prepareForEditing(registry: VaccineRegistry) {
        
        guard registry.managedObjectContext === context else {
            errorMessage = "O registro e a viewModel estão usando contextos diferentes"
            return
        }
        guard let savedApplicationDate = registry.applicationDate else { return }
        
        applicationDate = savedApplicationDate
        selectedVaccine = registry.vaccine
        registryBeingEdited = registry
        errorMessage = nil
    }
    
    func saveRegistry() -> Bool {
        
        guard let selectedVaccine else {
            errorMessage = "Selecione uma vacina"
            return false
        }
        
        guard selectedVaccine.managedObjectContext === context else {
            errorMessage = "A vacina selecionada não pertence ao contexto"
            return false
        }
        
       let vaccineRegistry: VaccineRegistry
        
        if let registryBeingEdited {
            guard registryBeingEdited.managedObjectContext === context else {
                
                errorMessage = "O Registro e a viewModel estão usando contextos diferentes"
                print("Contextos diferentes")
                return false
            }
            vaccineRegistry = registryBeingEdited
            
        } else {
            vaccineRegistry = VaccineRegistry(context: context)
            vaccineRegistry.id = UUID()
            
        }
        vaccineRegistry.vaccine = selectedVaccine
        vaccineRegistry.applicationDate = applicationDate
        
        do {
            try context.save()
            prepareNewRegistry()
            
            return true
        } catch {
            context.rollback()
            
            errorMessage = "Não foi possível salvar o registro: \(error.localizedDescription)"
            return false
        }
    }
    
    func deleteRegistry(_ registry: VaccineRegistry) {
        
        guard registry.managedObjectContext === context else {
            errorMessage = "O Registro e a viewModel estão usando contextos diferentes"
            return
        }
        context.delete(registry)
        
        do {
            try context.save()
            errorMessage = nil
            registryBeingEdited = nil
        } catch {
            context.rollback()
            errorMessage = "Não foi possível excluir o registro: \(error.localizedDescription)"
            
        }
    }
    
    func cancelEditing() {
        prepareNewRegistry()
    }
}
