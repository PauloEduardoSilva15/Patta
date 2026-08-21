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
    var weight: Double?
    var breed: String
    var birthdate: Date?
    var medicalConditions: String
    var errorMessage = ""
    
    private let store: PetListStore
    
    init(petImage: Data? = nil, name: String, weight: Double? = nil, breed: String = "", birthdate: Date? = nil, medicalConditions: String = "", store: PetListStore) {
        self.petImage = petImage
        self.name = name
        self.weight = weight
        self.breed = breed
        self.birthdate = birthdate
        self.medicalConditions = medicalConditions
        self.store = store
    }
    
    func addNewPet() throws {
        
        guard !name.isEmpty else {
            throw ValidationError.emptyProperty
        }
        
        let newPet = PetModel(id: UUID(), name: name, weight: weight, breed: breed, birthdate: birthdate, medicalConditions: medicalConditions, image: petImage)
        
        do {
            try store.add(newPet)
            clearForm()
        } catch {
            errorMessage = error.localizedDescription
            throw ValidationError.saveFailed(description: error)
        }
    }
    
    func updatePet(id: UUID) throws {
        
        guard !name.isEmpty else { throw ValidationError.emptyProperty }
        
        let updatedPet = PetModel(id: id, name: name, weight: weight, breed: breed, birthdate: birthdate, medicalConditions: medicalConditions, image: petImage)
        
        do {
            try store.update(updatedPet)
            clearForm()
        } catch {
            errorMessage = error.localizedDescription
            throw ValidationError.saveFailed(description: error)
        }
    }
    
    func deletePet(id: UUID) {
        do {
            try store.delete(id: id)
        } catch {
            errorMessage = error.localizedDescription
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
    
    func getAge(birthdate: Date) -> String {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthdate, to: Date())
        return String(ageComponents.year!)
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
