//
//  TaskModel.swift
//  Patta
//
//  Created by Pedro Canute on 22/08/26.
//
import SwiftData
import Foundation

// MARK: - TaskModel
@Model
final class TaskModel: @unchecked Sendable {
    @Attribute(.unique) var id: UUID
    var title: String
    var taskDescription: String
    
    var createdAt: Date
    var date: Date?
    var completedAt: Date?
    
    var usesCustomDate: Bool?
    var isPriority: Bool
    var isRecurring: Bool
    var recurrenceEndDate: Date?
    var isCompleted: Bool
    
    @Relationship(inverse: \PetModel.tasks) var pet: PetModel?
    
    var appliesToAllPets: Bool?
    
    init(
        id: UUID = UUID(),
        title: String,
        taskDescription: String = "",
        createdAt: Date = Date(),
        date: Date? = nil,
        completedAt: Date? = nil,
        usesCustomDate: Bool? = nil,
        isPriority: Bool = false,
        isRecurring: Bool = false,
        recurrenceEndDate: Date? = nil,
        isCompleted: Bool = false,
        pet: PetModel? = nil
    ) {
        self.id = id
        self.title = title
        self.taskDescription = taskDescription
        self.createdAt = createdAt
        self.date = date
        self.completedAt = completedAt
        self.usesCustomDate = usesCustomDate
        self.isPriority = isPriority
        self.isRecurring = isRecurring
        self.recurrenceEndDate = recurrenceEndDate
        self.isCompleted = isCompleted
        self.pet = pet
    }
}

// MARK: - Equatable & Hashable
extension TaskModel: Equatable {
    nonisolated static func == (lhs: TaskModel, rhs: TaskModel) -> Bool {
        lhs.id == rhs.id
    }
}

extension TaskModel: Hashable {
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

