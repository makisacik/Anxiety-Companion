//
//  ReminderScheduler.swift
//  AnxietyTest&Companion
//
//  Created by Mehmet Ali Kısacık on 26.10.2025.
//

import Foundation
import UserNotifications

final class ReminderScheduler {
    static let shared = ReminderScheduler()
    
    private init() {}
    
    private let notificationIdentifier = "calmReminder"
    
    /// Requests notification permission from the user
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Notification authorization error: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                if granted {
                    // Immediately schedule a reminder if permission granted
                    self.scheduleReminder()
                }
                
                completion(granted)
            }
        }
    }
    
    /// Schedules a soft reminder after N days (default randomized between 3–5 days)
    func scheduleReminder(afterDays days: Double? = nil) {
        // First check if we have permission
        checkAuthorizationStatus { [weak self] hasPermission in
            guard hasPermission else {
                print("Cannot schedule reminder: no notification permission")
                return
            }
            
            self?.performScheduling(afterDays: days)
        }
    }
    
    private func performScheduling(afterDays days: Double?) {
        // Cancel any existing reminders first
        cancelReminders()
        
        // Calculate interval (randomize between 3-5 days if not specified)
        let intervalDays = days ?? Double.random(in: 3...5)
        let intervalSeconds = intervalDays * 24 * 60 * 60
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time for your calm check-in 🌤️"
        content.body = "Take a moment to reflect on how you've been feeling lately."
        content.sound = .default
        
        // Create trigger (repeating)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: intervalSeconds, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: trigger
        )
        
        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule reminder: \(error.localizedDescription)")
            } else {
                print("Reminder scheduled for \(intervalDays) days from now")
            }
        }
    }
    
    /// Cancels all pending "calmReminder" notifications
    func cancelReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
        print("Cancelled all pending reminders")
    }
    
    /// Checks current notification permission status
    func checkAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                let isAuthorized = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
                completion(isAuthorized)
            }
        }
    }
    
    /// Reschedules a new reminder if none exist
    func rescheduleIfNeeded() {
        checkAuthorizationStatus { [weak self] hasPermission in
            guard hasPermission else { return }
            
            // Check if we have any pending reminders
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                let hasReminder = requests.contains { $0.identifier == self?.notificationIdentifier }
                
                if !hasReminder {
                    print("No pending reminders found, rescheduling...")
                    self?.scheduleReminder()
                }
            }
        }
    }
}
