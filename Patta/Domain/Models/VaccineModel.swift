//
//  VaccineModel.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 21/08/26.
//

import Foundation
import SwiftData

@Model
class VaccineModel: Identifiable, Equatable, Hashable {
    var id: UUID
    var title: String
    var vaccineRegistries: [VaccineRegistryModel]?
    
    init(id: UUID, title: String, vaccineRegistries: [VaccineRegistryModel]? = []) {
        self.id = id
        self.title = title
        self.vaccineRegistries = vaccineRegistries
    }
}
