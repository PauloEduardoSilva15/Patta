//
//  PetModel.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 20/08/26.
//

import Foundation
import SwiftData

@Model
class PetModel: Identifiable, Equatable, Hashable {
    var id: UUID
    var name: String
    var weight: Double?
    var breed: String?
    var birthdate: Date?
    var medicalConditions: String?
    @Attribute(.externalStorage) var image: Data?
    var color: String? = PetColorPalette.defaultAssetName
    
    init(id: UUID, name: String, weight: Double? = nil, breed: String? = nil, birthdate: Date? = nil, medicalConditions: String? = nil, image: Data? = nil, color: String? = nil) {
        self.id = id
        self.name = name
        self.weight = weight
        self.breed = breed
        self.birthdate = birthdate
        self.medicalConditions = medicalConditions
        self.image = image
        self.color = color
    }
}
