//
//  VaccineRepositoryProtocol.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 21/08/26.
//

import Foundation

protocol VaccineRepositoryProtocol {
    func fetchAll() throws -> [VaccineModel]
    func add(_ vaccine: VaccineModel) throws
    func update(_ vaccine: VaccineModel) throws
    func delete(id: UUID) throws
}
