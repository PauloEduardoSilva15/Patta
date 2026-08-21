//
//  PetModel.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 20/08/26.
//

import Foundation

struct PetModel: Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var weight: Double?
    var breed: String?
    var birthdate: Date?
    var medicalConditions: String?
    var image: Data?
}
