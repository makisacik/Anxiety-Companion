//
//  WorryTrackerViewModel.swift
//  AnxietyTest&Companion
//
//  Created by GitHub Copilot on 29.10.2025.
//

import Foundation
import CoreData
import UserNotifications
import Combine

@MainActor
class WorryTrackerViewModel: ObservableObject {
    @Published var pending: [WorryLog] = []
    @Published var ready: [WorryLog] = []
    @Published var completed: [WorryLog] = []
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        refresh()
    }
    
    func refresh() {
        let request: NSFetchRequest<WorryLog> = WorryLog.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WorryLog.dateCreated, ascending: false)]
        
        if let all = try? context.fetch(request) {
            let now = Date()
            pending = all.filter { !$0.isAnswered && ($0.reminderDate ?? .distantFuture) > now }
            ready = all.filter { !$0.isAnswered && ($0.reminderDate ?? .distantPast) <= now }
            completed = all.filter { $0.isAnswered }
        }
    }
    
    func addWorry(text: String, control: String?, intensity: Int, reminderDate: Date) {
        let new = WorryLog(context: context)
        new.id = UUID()
        new.worryText = text
        new.controlThought = control
        new.intensity = Int16(intensity)
        new.dateCreated = Date()
        new.reminderDate = reminderDate
        new.isAnswered = false
        new.wasBetter = false
        
        do {
            try context.save()
            scheduleReminder(for: new)
            refresh()
        } catch {
            print("❌ Error saving worry: \(error)")
        }
    }
    
    func answerWorry(_ worry: WorryLog, wasBetter: Bool) {
        worry.wasBetter = wasBetter
        worry.isAnswered = true
        
        do {
            try context.save()
            refresh()
        } catch {
            print("❌ Error answering worry: \(error)")
        }
    }
    
    func deleteWorry(_ worry: WorryLog) {
        // Cancel notification
        if let id = worry.id {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
        }
        
        context.delete(worry)
        
        do {
            try context.save()
            refresh()
        } catch {
            print("❌ Error deleting worry: \(error)")
        }
    }
    
    private func scheduleReminder(for worry: WorryLog) {
        guard let date = worry.reminderDate, let id = worry.id else { return }
        
        // Request notification permission first
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = "Reflect on your worry 🌿"
                content.body = "Was it better than expected?"
                content.sound = .default
                
                let timeInterval = date.timeIntervalSinceNow
                if timeInterval > 0 {
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
                    let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print("❌ Error scheduling notification: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    func timeLeftString(for date: Date) -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.hour, .minute], from: now, to: date)
        
        if let hours = components.hour, let minutes = components.minute {
            if hours > 0 {
                return String.localizedStringWithFormat(String(localized: "worry_time_left_hours"), hours, minutes)
            } else if minutes > 0 {
                return String.localizedStringWithFormat(String(localized: "worry_time_left_minutes"), minutes)
            } else {
                return String(localized: "worry_time_left_soon")
            }
        }
        return String(localized: "worry_time_left_soon")
    }
}
