//
//  PetViewModel.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 17/08/26.
//

import Foundation
import Observation
import CoreData
import _PhotosUI_SwiftUI

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
    var breed: String
    var birthdate: Date?
    var medicalConditions: String
    var errorMessage = ""
    
    private let context: NSManagedObjectContext
    
    init(petImage: Data? = nil, name: String, weight: Int? = nil, breed: String = "", birthdate: Date? = nil, medicalConditions: String = "", context: NSManagedObjectContext) {
        self.petImage = petImage
        self.name = name
        self.weight = weight
        self.breed = breed
        self.birthdate = birthdate
        self.medicalConditions = medicalConditions
        self.context = context
    }
    
    func getAge(birthdate: Date) -> String {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthdate, to: Date())
        return String(ageComponents.year!)
    }
    
    func addNewPet() throws {
        
        guard !name.isEmpty else {
            throw ValidationError.emptyProperty
        }
        
        let newPet = Pet(context: context)
        
        newPet.id = UUID()
        
        insertData(pet: newPet)
        trySaveChanges()
        clearForm()
    }
    
    func updatePet(_ editingPet: Pet) throws {
        
        guard context.hasChanges else { return }
        
        guard !name.isEmpty else { throw ValidationError.emptyProperty }
        
        insertData(pet: editingPet)
        trySaveChanges()
        clearForm()
    }
    
    func deletePet(_ pet: Pet) {
        context.delete(pet)
        
        trySaveChanges()
    }
    
    private func insertData(pet: Pet) {
        pet.name = name
        pet.weight = NSDecimalNumber(integerLiteral: weight ?? 0)
        pet.breed = breed
        pet.birthdate = birthdate
        pet.med_cond = medicalConditions
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
    
    func loadImage(from image: PhotosPickerItem?) async -> Data? {
        errorMessage = ""
        
        do {
            return try await image?.loadTransferable(type: Data.self)
        } catch {
            errorMessage = "Não foi possível carregar a foto. Tente novamente."
        }
        
        return nil
    }
    
    func clearForm() {
        name = ""
        weight = nil
        petImage = nil
        breed = ""
        birthdate = nil
        medicalConditions = ""
        errorMessage = ""
    }
}
