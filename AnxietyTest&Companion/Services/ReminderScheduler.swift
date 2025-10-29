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
    
    // Legacy identifier (kept for backward compatibility, but no longer used by default)
    private let notificationIdentifier = "calmReminder"

    // MARK: - New categories and policy
    enum Category: String {
        case reflection = "reflectionReminder"
        case weeklyTest = "weeklyTestReminder"
    }

    // Throttling policy: at most 1 non-worry notification every 72 hours
    private let nonWorryCooldown: TimeInterval = 72 * 60 * 60
    // Quiet hours: user-configurable (defaults 21:00–08:00)
    private var quietHoursEnabled: Bool {
        UserDefaults.standard.bool(forKey: "quietHoursEnabled")
    }
    private var quietStartHour: Int {
        let h = UserDefaults.standard.integer(forKey: "quietStartHour")
        return (0...23).contains(h) ? h : 21
    }
    private var quietEndHour: Int {
        let h = UserDefaults.standard.integer(forKey: "quietEndHour")
        return (0...23).contains(h) ? h : 8
    }

    // UserDefaults keys
    private let lastNonWorryKey = "lastNonWorryNotificationTimestamp"
    private let lastReflectionSentKey = "lastReflectionNotificationTimestamp"
    private let lastWeeklyTestSentKey = "lastWeeklyTestNotificationTimestamp"
    
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
                    // Immediately evaluate and schedule category-based reminders under new policy
                    self.evaluateAndScheduleIfNeeded()
                }
                
                completion(granted)
            }
        }
    }
    
    // MARK: - Public evaluation entry-point
    /// Evaluate current state and schedule eligible non-worry reminders (reflection, weekly test)
    /// Enforces global 72h cooldown between non-worry notifications and quiet hours.
    func evaluateAndScheduleIfNeeded(now: Date = Date()) {
        checkAuthorizationStatus { [weak self] hasPermission in
            guard let self = self, hasPermission else { return }

            // Respect optional master toggle if used in app
            let notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
            guard notificationsEnabled else { return }

            // Determine eligibility windows
            let ud = UserDefaults.standard

            // Last GAD7 test date (AppStorage-backed key used across the app)
            let lastGAD7Timestamp = ud.double(forKey: "lastGAD7DateTimestamp")
            let lastGAD7Date = lastGAD7Timestamp > 0 ? Date(timeIntervalSince1970: lastGAD7Timestamp) : nil

            // Last reflection completion date (we'll set this when user saves in ReflectionView)
            let lastReflectionTimestamp = ud.double(forKey: "lastReflectionDateTimestamp")
            let lastReflectionDate = lastReflectionTimestamp > 0 ? Date(timeIntervalSince1970: lastReflectionTimestamp) : nil

            // Last non-worry notification sent time
            let lastNonWorryTs = ud.double(forKey: self.lastNonWorryKey)
            let lastNonWorryDate = lastNonWorryTs > 0 ? Date(timeIntervalSince1970: lastNonWorryTs) : nil

            // Helper to check 72h cooldown
            func isCooldownSatisfied(since date: Date?) -> Bool {
                guard let date else { return true }
                return now.timeIntervalSince(date) >= self.nonWorryCooldown
            }

            // Priority: Reflection (if 2+ days since last reflection), then Weekly Test (7+ days)
            var scheduledSomething = false

            if self.isReflectionEligible(lastReflectionDate: lastReflectionDate, now: now),
               isCooldownSatisfied(since: lastNonWorryDate) {
                let scheduleDate = self.preferredReflectionTime(from: now)
                self.schedule(.reflection, at: scheduleDate)
                ud.set(scheduleDate.timeIntervalSince1970, forKey: self.lastNonWorryKey)
                ud.set(scheduleDate.timeIntervalSince1970, forKey: self.lastReflectionSentKey)
                scheduledSomething = true
            }

            if !scheduledSomething,
               self.isWeeklyTestEligible(lastTestDate: lastGAD7Date, now: now),
               isCooldownSatisfied(since: lastNonWorryDate) {
                let scheduleDate = self.preferredWeeklyTestTime(from: now)
                self.schedule(.weeklyTest, at: scheduleDate)
                ud.set(scheduleDate.timeIntervalSince1970, forKey: self.lastNonWorryKey)
                ud.set(scheduleDate.timeIntervalSince1970, forKey: self.lastWeeklyTestSentKey)
            }
        }
    }

    // MARK: - Eligibility rules
    private func isReflectionEligible(lastReflectionDate: Date?, now: Date) -> Bool {
        // Eligible if no reflection in last 2 days
        guard let last = lastReflectionDate else { return true }
        let days = Calendar.current.dateComponents([.day], from: last, to: now).day ?? 0
        return days >= 2
    }
    
    private func isWeeklyTestEligible(lastTestDate: Date?, now: Date) -> Bool {
        // Eligible if 7+ days since last GAD-7
        guard let last = lastTestDate else { return true }
        let days = Calendar.current.dateComponents([.day], from: last, to: now).day ?? 0
        return days >= 7
    }

    // MARK: - Preferred times and quiet-hour handling
    private func isInQuietHours(_ date: Date) -> Bool {
        guard quietHoursEnabled else { return false }
        let hour = Calendar.current.component(.hour, from: date)
        // If the window crosses midnight (e.g., 21 -> 8), then hour >= start OR hour < end
        if quietStartHour > quietEndHour {
            return hour >= quietStartHour || hour < quietEndHour
        } else if quietStartHour < quietEndHour {
            // Same-day window (e.g., 12 -> 18)
            return hour >= quietStartHour && hour < quietEndHour
        } else {
            // start == end => no quiet hours
            return false
        }
    }

    private func nextSafeDate(from date: Date, defaultHour: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        // If currently in quiet hours, move to next day at defaultHour; else use today at defaultHour or next occurrence
        if isInQuietHours(date) || components.hour! >= defaultHour {
            // Move to next day
            if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: date) {
                return Calendar.current.date(bySettingHour: defaultHour, minute: 0, second: 0, of: nextDay) ?? date.addingTimeInterval(24*60*60)
            }
        }
        // Today at defaultHour
        return Calendar.current.date(bySettingHour: defaultHour, minute: 0, second: 0, of: date) ?? date
    }

    private func preferredReflectionTime(from now: Date) -> Date {
        // Evenings feel more natural (20:00), adjusted for quiet hours
        let target = nextSafeDate(from: now, defaultHour: 20)
        return adjustForQuietHours(target)
    }

    private func preferredWeeklyTestTime(from now: Date) -> Date {
        // Mid-morning (10:00) on Tue-Thu if possible; otherwise next safe 10:00
        var date = nextSafeDate(from: now, defaultHour: 10)
        var weekday = Calendar.current.component(.weekday, from: date) // 1=Sun
        // If it's Mon(2) or Fri/Sat/Sun, shift to Tue-Thu
        if weekday == 2 || weekday == 6 || weekday == 7 || weekday == 1 { // Mon/Fri/Sat/Sun
            // Move forward day-by-day until Tue-Thu
            while true {
                date = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date
                weekday = Calendar.current.component(.weekday, from: date)
                if weekday == 3 || weekday == 4 || weekday == 5 { break } // Tue-Thu
            }
            // Set hour to 10
            date = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: date) ?? date
        }
        return adjustForQuietHours(date)
    }

    private func adjustForQuietHours(_ date: Date) -> Date {
        guard isInQuietHours(date) else { return date }
        // Find the next time outside quiet hours; prefer the hour immediately after quietEndHour
        let nextDayIfNeeded: Date
        // If quiet window crosses midnight and date is in early morning (< quietEndHour), same day at quietEndHour is fine
        let hour = Calendar.current.component(.hour, from: date)
        if quietStartHour > quietEndHour && hour < quietEndHour {
            nextDayIfNeeded = date
        } else {
            // Otherwise, move to next day
            nextDayIfNeeded = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date
        }
        return Calendar.current.date(bySettingHour: quietEndHour, minute: 0, second: 0, of: nextDayIfNeeded) ?? nextDayIfNeeded
    }

    // MARK: - Scheduling primitives
    private func schedule(_ category: Category, at date: Date) {
        let content = UNMutableNotificationContent()
        switch category {
        case .reflection:
            content.title = "A gentle pause ✨"
            content.body = "If it feels okay, write a few honest lines about today. No pressure."
        case .weeklyTest:
            content.title = "Weekly check-in 📊"
            content.body = "When you’re ready, take a moment to see how this week felt. One step at a time."
        }
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: category.rawValue, content: content, trigger: trigger)

        // Cancel existing request for this category before scheduling new
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [category.rawValue])
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule \(category.rawValue): \(error.localizedDescription)")
            } else {
                print("Scheduled \(category.rawValue) at \(date)")
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
        let ids = [notificationIdentifier, Category.reflection.rawValue, Category.weeklyTest.rawValue]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        print("Cancelled all pending reminders (legacy + categories)")
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
            
            // Remove legacy repeating reminder to avoid conflicts and evaluate new category-based ones
            if let legacyId = self?.notificationIdentifier {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [legacyId])
            }
            self?.evaluateAndScheduleIfNeeded()
        }
    }
}
