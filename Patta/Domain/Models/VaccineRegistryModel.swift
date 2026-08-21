//
//  VaccineRegistryModel.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 21/08/26.
//

import Foundation

struct VaccineRegistryModel: Identifiable, Equatable {
    let id: UUID
    var applicationDate: Date?
    var vaccine: VaccineModel
    var petId: UUID?
}
