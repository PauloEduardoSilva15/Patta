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
    var vaccine: VaccineModel
    var petId: UUID?
    
    init(id: UUID, applicationDate: Date? = nil, vaccine: VaccineModel, petId: UUID? = nil) {
        self.id = id
        self.applicationDate = applicationDate
        self.vaccine = vaccine
        self.petId = petId
    }
}
