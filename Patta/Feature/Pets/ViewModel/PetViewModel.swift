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

@MainActor
@Observable
final class PetViewModel {
    var petImage: Data?
    var name = ""
    var weight: Decimal?
    var breed = ""
    var birthdate: Date?
    var medicalConditions = ""
    var errorMessage: String?
    
    var petBeingEdited: Pet?
    
    private let context: NSManagedObjectContext
    
    var isEditing: Bool {
        petBeingEdited != nil
    }
    
    var formTitle: String {
        isEditing ? "Editar Pet" : "Adicionar Pet"
    }
    
    static let defaultColorName = "petAzul"

    var selectedColorName = PetViewModel.defaultColorName
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func prepareNewPet() {
        resetForm()
    }
    
    func prepareToEdit(_ pet: Pet) {
        guard pet.managedObjectContext === context else {
            errorMessage = "Erro ao carregar o pet"
            return
        }
        
        petBeingEdited = pet
        
        name = pet.name ?? ""
        weight = pet.weight?.decimalValue
        breed = pet.breed ?? ""
        birthdate = pet.birthdate
        medicalConditions = pet.med_cond ?? ""
        petImage = pet.image
        selectedColorName = pet.color ?? PetViewModel.defaultColorName
        
        errorMessage = nil
    }
    
    func savePet() -> Bool {
        let treatedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !treatedName.isEmpty else {
            errorMessage = "O nome do pet não pode ser vazio"
            return false
        }
        
        if let birthdate, birthdate > Date() {
            errorMessage = "A data de nascimento não pode ser futura"
            return false
        }
        
        let petToSave: Pet
        
        print("Está editando:", petBeingEdited != nil)
        print("Nome recebido:", treatedName)
        
        if let petBeingEdited {
            guard petBeingEdited.managedObjectContext === context else {
                errorMessage = "O pet e a viewmodel estao usando contextos diferentes"
                return false
            }
            
            petToSave = petBeingEdited
        } else {
            petToSave = Pet(context: context)
            petToSave.id = UUID()
        }
        
            petToSave.name = treatedName
            petToSave.image = petImage
            petToSave.breed = breed
            petToSave.birthdate = birthdate
            petToSave.med_cond = medicalConditions

            if let weight {
                petToSave.weight = NSDecimalNumber(decimal: weight)
            } else {
                petToSave.weight = nil
            }
        
        do {
            if context.hasChanges {
                try context.save()
                print(
                    "Pet salvo:",
                    petToSave.objectID.uriRepresentation()
                )
            }
            resetForm()
            return true
        } catch {
            context.rollback()
            
            let nsError = error as NSError
            print("Erro Core Data:", nsError)
            print("Detalhes:", nsError.userInfo)
            
            errorMessage = "Erro ao salvar o pet: \(nsError.localizedDescription)"
            return false
        }
    }
    
    func deletePet(_ pet: Pet) -> Bool {
        guard pet.managedObjectContext === context else {
            errorMessage = "O pet e a viewmodel estao usando contextos diferentes"
            return false
        }
        
        let wasBeingEdited = petBeingEdited?.objectID == pet.objectID
        
        context.delete(pet)
        
        do {
            try context.save()
            if wasBeingEdited {
                resetForm()
            } else {
                errorMessage = nil
            }
            return true
        } catch {
            context.rollback()
            let nsError = error as NSError
            errorMessage = "Erro ao excluir o pet: \(nsError.localizedDescription)"
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
    
    func getAge(birthdate: Date) -> String {
        guard birthdate <= Date() else {
            return "0"
        }
        
        let components = Calendar.current.dateComponents([.year], from: birthdate, to: Date())
        return String(components.year ?? 0)
        
    }
    
    func cancelEditing() {
        resetForm()
    }
    
    func applyFormData(to pet: Pet, treatedName: String) {
        pet.name = treatedName
        pet.weight = weight.map { NSDecimalNumber(decimal: $0) }
        pet.breed = breed.trimmingCharacters(in: .whitespacesAndNewlines)
        pet.birthdate = birthdate
        pet.med_cond = medicalConditions.trimmingCharacters(in: .whitespacesAndNewlines)
        pet.image = petImage
        pet.color = selectedColorName
        
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
//
//
////    ===============
//    func getAge(birthdate: Date) -> String {
//        let calendar = Calendar.current
//        let ageComponents = calendar.dateComponents([.year], from: birthdate, to: Date())
//        return String(ageComponents.year!)
//    }
//    
//    func addNewPet() throws {
//        
//        guard !name.isEmpty else {
//            throw ValidationError.emptyProperty
//        }
//        
//        let newPet = Pet(context: context)
//        
//        newPet.id = UUID()
//        
//        insertData(pet: newPet)
//        trySaveChanges()
//        clearForm()
//    }
//    
//    func updatePet(_ editingPet: Pet) throws {
//        
////        guard context.hasChanges else { return }
//        
//        guard !name.isEmpty else { throw ValidationError.emptyProperty }
//        
//        insertData(pet: editingPet)
//        trySaveChanges()
//        clearForm()
//    }
//    
//    func deletePet(_ pet: Pet) {
//        context.delete(pet)
//        
//        trySaveChanges()
//    }
//    
//    private func insertData(pet: Pet) {
//        pet.name = name
//        pet.weight = NSDecimalNumber(integerLiteral: weight ?? 0)
//        pet.breed = breed
//        pet.birthdate = birthdate
//        pet.med_cond = medicalConditions
//        pet.image = petImage ?? nil
//    }
//    
//    private func trySaveChanges() {
//        do {
//            try saveChanges()
//        } catch let error as ValidationError {
//            errorMessage = error.localizedDescription
//            print(error.localizedDescription)
//        } catch {
//            errorMessage = error.localizedDescription
//            print(error.localizedDescription)
//        }
//    }
//    
//    private func saveChanges() throws {
//        do {
//            try context.save()
//            clearForm()
//        } catch {
//            context.rollback()
//            throw ValidationError.saveFailed(description: error)
//        }
//    }
//    
//    func loadImage(from image: PhotosPickerItem?) async -> Data? {
//        errorMessage = ""
//        
//        do {
//            return try await image?.loadTransferable(type: Data.self)
//        } catch {
//            errorMessage = "Não foi possível carregar a foto. Tente novamente."
//        }
//        
//        return nil
//    }
//    
//    func clearForm() {
//        name = ""
//        weight = nil
//        petImage = nil
//        breed = ""
//        birthdate = nil
//        medicalConditions = ""
//        errorMessage = ""
//    }
//}
