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
    
    init(id: UUID, title: String) {
        self.id = id
        self.title = title
    }
}
