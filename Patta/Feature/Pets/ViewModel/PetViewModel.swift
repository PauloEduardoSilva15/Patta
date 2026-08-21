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
    var name: String
    var weight: Double?
    var breed: String
    var birthdate: Date?
    var medicalConditions = ""
    var errorMessage: String?
    
    private var petBeingEditedId: UUID?
    
    private let store: PetListStore
    
    var isEditing: Bool {
        petBeingEditedId != nil
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
        petBeingEditedId = pet.id
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

        let petToSave = PetModel(
            id: petBeingEditedId ?? UUID(),
            name: treatedName,
            weight: weight,
            breed: breed.trimmingCharacters(in: .whitespacesAndNewlines),
            birthdate: birthdate,
            medicalConditions: medicalConditions.trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            image: petImage,
            color: PetColorPalette.normalizedAssetName(selectedColorName)
        )

        do {
            if !isEditing {
                try store.add(petToSave)
            } else {
                try store.update(petToSave)
            }
            resetForm()
            return true
        } catch {
            let nsError = error as NSError
            errorMessage = """
            Erro ao salvar o pet: \(nsError.localizedDescription)
            """

            return false
        }
    }
    
    func deletePet(id: UUID) -> Bool {
        do {
            try store.delete(id: id)
            if petBeingEditedId == id {
                resetForm()
            } else {
                errorMessage = nil
            }
            return true
        } catch {
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
    
    private func resetForm() {
        petBeingEditedId = nil
        
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
