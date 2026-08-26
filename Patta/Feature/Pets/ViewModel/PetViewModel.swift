//
//  PetViewModel.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 17/08/26.
//

import Foundation
import Observation
import _PhotosUI_SwiftUI

@Observable
final class PetViewModel {
    var petImage: Data?
    var name: String
    var weight: Double?
    var breed: String
    var birthdate: Date?
    var medicalConditions = ""
    var errorMessage: String?
    
    private var petBeingEdited: PetModel?
    
    private let store: PetListStore
    
    var isEditing: Bool {
        petBeingEdited != nil
    }
    
    var formTitle: String {
        isEditing ? "Editar Pet" : "Adicionar Pet"
    }
    
    static let defaultColorName = PetColorPalette.defaultAssetName
    
    var selectedColorName = PetViewModel.defaultColorName
    
    init(name: String = "", store: PetListStore) {
        self.name = name
        self.weight = nil
        self.breed = ""
        self.birthdate = nil
        self.store = store
    }
    
    func prepareNewPet() {
        resetForm()
    }
    
    func prepareToEdit(_ pet: PetModel) {
        petBeingEdited = pet
        name = pet.name
        weight = pet.weight
        breed = pet.breed ?? ""
        birthdate = pet.birthdate
        medicalConditions = pet.medicalConditions ?? ""
        petImage = pet.image
        selectedColorName = PetColorPalette.normalizedAssetName(
            pet.color
        )
        errorMessage = nil
    }
    
    func savePet() -> Bool {
        let treatedName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        
        guard !treatedName.isEmpty else {
            errorMessage = "O nome do pet não pode ser vazio"
            return false
        }
        
        if let birthdate, birthdate > Date() {
            errorMessage = "A data de nascimento não pode ser futura"
            return false
        }
        
        do {
            if let petBeingEdited {
                petBeingEdited.name = treatedName
                petBeingEdited.weight = weight
                petBeingEdited.breed = breed
                petBeingEdited.birthdate = birthdate
                petBeingEdited.medicalConditions = medicalConditions
                petBeingEdited.image = petImage
                petBeingEdited.color = PetColorPalette.normalizedAssetName(selectedColorName)
                try store.update(petBeingEdited)
            } else {
                let newPet = PetModel(
                    id: UUID(),
                    name: treatedName,
                    weight: weight,
                    breed: breed,
                    birthdate: birthdate,
                    medicalConditions: medicalConditions,
                    image: petImage,
                    color: PetColorPalette.normalizedAssetName(selectedColorName)
                )
                try store.add(newPet)
            }
            
            return true
        } catch {
            errorMessage = "Erro ao salvar o pet: \(error.localizedDescription)"
            return false
        }
    }
    
    func deletePet(id: UUID) -> Bool {
        do {
            try store.delete(id: id)
            return true
        } catch {
            errorMessage = "Erro ao excluir o pet: \(error.localizedDescription)"
            return false
        }
    }
    
    func loadImage(from item: PhotosPickerItem?) async -> Data? {
        errorMessage = nil
        
        guard let item else {
            return nil
        }
        
        do {
            guard let imageData = try await item.loadTransferable(type: Data.self) else {
                errorMessage = "Não foi possível carregar a imagem"
                return nil
            }
            petImage = imageData
            return imageData
        } catch {
            errorMessage = "Não foi possível carregar a imagem"
            return nil
        }
    }
    
    func removeImage() {
        petImage = nil
    }
    
    func getAge(birthdate: Date?) -> String {
        if birthdate == nil {
            return "Não informado"
        } else {
            let yearComponent = Calendar.current.dateComponents([.year], from: birthdate!, to: Date())
            let monthComponent = Calendar.current.dateComponents([.month], from: birthdate!, to: Date())
            let dayComponent = Calendar.current.dateComponents([.day], from: birthdate!, to: Date())
            
            if yearComponent.year! > 0 {
                if yearComponent.year! == 1 {
                    return "\(yearComponent.year!) ano"
                } else {
                    return "\(yearComponent.year!) anos"
                }
            } else if monthComponent.month! > 0 {
                if monthComponent.month! == 1 {
                    return "\(monthComponent.month!) mês"
                } else {
                    return "\(monthComponent.month!) meses"
                }
            } else if dayComponent.day! > 0 {
                if dayComponent.day! == 1 {
                    return "\(dayComponent.day!) dia"
                } else {
                    return "\(dayComponent.day!) dias"
                }
            } else {
                return "Recém nascido"
            }
        }
    }
    
    func cancelEditing() {
        resetForm()
    }
    
    private func resetForm() {
        petBeingEdited = nil
        
        petImage = nil
        name = ""
        weight = nil
        breed = ""
        birthdate = nil
        medicalConditions = ""
        selectedColorName = PetViewModel.defaultColorName
        
        errorMessage = nil
    }
}
