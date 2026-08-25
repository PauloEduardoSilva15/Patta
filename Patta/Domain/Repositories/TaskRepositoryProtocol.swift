//
//  TaskRepositoryProtocol.swift
//  Patta
//
//  Created by Pedro Canute on 22/08/26.
//

import Foundation

protocol TaskRepositoryProtocol {
    func fetchAll() throws -> [TaskModel]
    func add(_ task: TaskModel) throws
    func update(_ task: TaskModel) throws
    func delete(id: UUID) throws
}
