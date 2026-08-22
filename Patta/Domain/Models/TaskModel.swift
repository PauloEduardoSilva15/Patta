//
//  TaskModel.swift
//  Patta
//
//  Created by Pedro Canute on 22/08/26.
//
import Foundation

struct TaskModel: Identifiable, Equatable , Hashable {
    let id: UUID
    var title: String
    var description: String
    
    var createdAt: Date
    var date: Date?
    var completedAt: Date?
    
    var usesCustomDate: Bool?
    var isPriority: Bool
    var isRecurring: Bool
    var recurrenceEndDate: Date?
    var isCompleted: Bool
    
    var pet: PetModel?
    var appliesToAllPets: Bool {
        pet == nil
    }
}
