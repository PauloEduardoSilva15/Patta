//
//  TaskListStore.swift
//  Patta
//
//  Created by Pedro Canute on 22/08/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class TaskListStore {
    private(set) var tasks: [TaskModel] = []
    
    private let repository: TaskRepositoryProtocol
    
    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }
    
    func refresh() throws {
        tasks = try repository.fetchAll()
    }
    
    func add(_ task: TaskModel) throws {
        try repository.add(task)
        try refresh()
    }
    
    func update(_ task: TaskModel) throws {
        try repository.update(task)
        try refresh()
    }
    
    func delete(id: UUID) throws {
        try repository.delete(id: id)
        try refresh()
    }
}
