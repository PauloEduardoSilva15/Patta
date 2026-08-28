//
//  LocalNotificationService.swift
//  Patta
//
//  Created by Pedro Canute on 27/08/26.
//

import Foundation
import UserNotifications

enum NotificationAuthorizationState: Equatable {
    case notDetermined
    case authorized
    case denied
}

enum LocalNotificationError: LocalizedError {
    case permissionDenied
    case invalidDate
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "O Patta não possui permissão para enviar notificações."
            
        case .invalidDate:
            return "Escolha uma data futura para o alerta."
        }
    }
}

@MainActor
final class LocalNotificationService {
    private let notificationCenter =
        UNUserNotificationCenter.current()
    
    private let notificationDelegate =
        NotificationDelegate()
    
    init() {
        notificationCenter.delegate =
            notificationDelegate
    }
    
    func authorizationState() async -> NotificationAuthorizationState {
        let settings = await notificationCenter.notificationSettings()
        
        switch settings.authorizationStatus {
        case .notDetermined:
            return .notDetermined
            
        case .denied:
            return .denied
            
        case .authorized, .provisional, .ephemeral:
            return .authorized
            
        @unknown default:
            return .denied
        }
    }
    
    func requestPermission() async throws -> Bool {
        try await notificationCenter.requestAuthorization(options: [.alert, .sound])
    }
    
    func scheduleReminder(taskID: UUID, taskTitle: String, reminderDate: Date) async throws {
        let authorization = await authorizationState()
        
        guard authorization == .authorized else {
            throw LocalNotificationError.permissionDenied
        }
        
        guard reminderDate > Date() else {
            throw LocalNotificationError.invalidDate
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Lembrete do Patta"
        content.body = taskTitle
        content.sound = .default
        content.threadIdentifier = "task-reminders"
        content.userInfo = ["taskID": taskID.uuidString]
        
        var dateComponents =
            Calendar.current.dateComponents(
                [
                    .year,
                    .month,
                    .day,
                    .hour,
                    .minute
                ],
                from: reminderDate
            )
        
        dateComponents.calendar = Calendar.current
        dateComponents.timeZone = TimeZone.current
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false
        )
        
        guard trigger.nextTriggerDate() != nil else {
            throw LocalNotificationError.invalidDate
        }
        
        let identifier = reminderIdentifier(
            for: taskID
        )
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        notificationCenter
            .removeDeliveredNotifications(withIdentifiers: [identifier])
        
        try await notificationCenter.add(request)
    }
    
    func cancelReminder(for taskID: UUID) {
        let identifier = reminderIdentifier(
            for: taskID
        )
        
        notificationCenter
            .removePendingNotificationRequests(withIdentifiers: [identifier])
        
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
    }
    
    private func reminderIdentifier(for taskID: UUID) -> String {
        "task-reminder-\(taskID.uuidString)"
    }
}
