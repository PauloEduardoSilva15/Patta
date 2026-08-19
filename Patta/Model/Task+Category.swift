//
//  Task+Category.swift
//  Patta
//
//  Created by Pedro Canute on 18/08/26.
//

import Foundation

extension Task {
    var taskCategory: TaskCategory? {
        get {
            guard let category else {
                return nil
            }
            return TaskCategory(rawValue: category)
        }
        
        set {
            category = newValue?.rawValue
        }
    }
}
