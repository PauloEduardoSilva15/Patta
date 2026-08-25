//
//  VaccineRegistryRepositoryProtocol.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 21/08/26.
//

import Foundation

protocol VaccineRegistryRepositoryProtocol {
    func fetchAll() throws -> [VaccineRegistryModel]
    func add(_ vaccineRegistry: VaccineRegistryModel) throws
    func update(_ vaccineRegistry: VaccineRegistryModel) throws
    func delete(id: UUID) throws
}
