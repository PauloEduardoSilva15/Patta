//
//  TaskModel.swift
//  Patta
//
//  Created by Pedro Canute on 22/08/26.
//
import SwiftData
import Foundation

@Model
final class TaskModel: Identifiable, Equatable, Hashable {
    var id: UUID
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
    
    
    
    var appliesToAllPets: Bool?
    
    var pet: PetModel?
    
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


