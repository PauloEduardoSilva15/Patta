//
//  PetRepositoryProtocol.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 20/08/26.
//

import Foundation

protocol PetRepositoryProtocol {
    func fetchAll() throws -> [PetModel]
    func add(_ pet: PetModel) throws
    func update(_ pet: PetModel) throws
    func delete(id: UUID) throws
}
