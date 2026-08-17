//
//  PetViewModel.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 17/08/26.
//

import Foundation
import Observation
import CoreData

enum ValidationError: Error {
    case emptyProperty
    case saveFailed(description: Error)
}

extension ValidationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .emptyProperty:
            return "Campo de nome não pode ser vazio!"
        case .saveFailed(let description):
            return "Erro ao salvar: \(description.localizedDescription)"
        }
    }
}


@Observable
class PetViewModel {
    var petImage: Data?
    var name: String
    var weight: Int?
    var breed: String?
    var birthdate: Date?
    var medicalConditions: String?
    var errorMessage = ""
    
    private let context: NSManagedObjectContext
    
    init(petImage: Data? = nil, name: String, weight: Int? = nil, breed: String? = nil, birthdate: Date? = nil, medicalConditions: String? = nil, context: NSManagedObjectContext) {
        self.petImage = petImage
        self.name = name
        self.weight = weight
        self.breed = breed
        self.birthdate = birthdate
        self.medicalConditions = medicalConditions
        self.context = context
    }
    
    func addNewPet() throws {
        
        guard !name.isEmpty else {
            throw ValidationError.emptyProperty
        }
        
        let newPet = Pet(context: context)
        
        insertData(pet: newPet)
        trySaveChanges()
    }
    
    func updatePet(_ editingPet: Pet) throws {
        
        guard context.hasChanges else { return }
        
        guard !name.isEmpty else { throw ValidationError.emptyProperty }
        
        insertData(pet: editingPet)
        trySaveChanges()
    }
    
    func deletePet(_ pet: Pet) {
        context.delete(pet)
        
        trySaveChanges()
    }
    
    private func insertData(pet: Pet) {
        pet.name = name
        pet.weight = NSDecimalNumber(integerLiteral: weight ?? 0)
        pet.breed = breed ?? nil
        pet.birthdate = birthdate ?? nil
        pet.med_cond = medicalConditions ?? nil
        pet.image = petImage ?? nil
    }
    
    private func trySaveChanges() {
        do {
            try saveChanges()
        } catch let error as ValidationError {
            errorMessage = error.localizedDescription
            print(error.localizedDescription)
        } catch {
            errorMessage = error.localizedDescription
            print(error.localizedDescription)
        }
    }
    
    private func saveChanges() throws {
        do {
            try context.save()
            clearForm()
        } catch {
            context.rollback()
            throw ValidationError.saveFailed(description: error)
        }
    }
    
    private func clearForm() {
        name = ""
        weight = nil
        petImage = nil
        breed = nil
        birthdate = nil
        medicalConditions = nil
        errorMessage = ""
    }
}
