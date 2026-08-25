//
//  VaccineRegistryModel.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 21/08/26.
//

import Foundation
import SwiftData

@Model
class VaccineRegistryModel: Identifiable, Equatable {
    var id: UUID
    var applicationDate: Date?
    
    @Relationship(deleteRule: .deny, inverse: \VaccineModel.vaccineRegistries)
    var vaccine: VaccineModel?
    
    var pet: PetModel
    
    init(id: UUID, applicationDate: Date? = nil, vaccine: VaccineModel? = nil, pet: PetModel) {
        self.id = id
        self.applicationDate = applicationDate
        self.vaccine = vaccine
        self.pet = pet
    }
}
