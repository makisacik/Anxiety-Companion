//
//  CalmingSessionManager.swift
//  AnxietyTest&Companion
//
//  Tracks session completion or streaks (future use).
//

import Foundation
import Combine

final class CalmingSessionManager: ObservableObject {
    @Published var lastCompletedActivityID: UUID?
    @Published var sessionStartTime: Date?
    @Published var currentActivityTitle: String?

    func startSession(for activity: CalmingActivity) {
        sessionStartTime = Date()
        currentActivityTitle = activity.title
    }

    func markActivityCompleted(_ activity: CalmingActivity, duration: Int? = nil) {
        lastCompletedActivityID = activity.id
        UserDefaults.standard.set(Date(), forKey: "lastCalmCompletionDate")

        // Save to CoreData if duration is provided
        if let duration = duration {
            DataManager.shared.saveActivityCompletion(
                activityTitle: activity.title,
                duration: duration
            )
        }

        // Reset session tracking
        sessionStartTime = nil
        currentActivityTitle = nil
    }

    func getSessionDuration() -> Int {
        guard let startTime = sessionStartTime else { return 0 }
        return Int(Date().timeIntervalSince(startTime))
    }

    var lastCompletionDate: Date? {
        UserDefaults.standard.object(forKey: "lastCalmCompletionDate") as? Date
    }

    var isSessionActive: Bool {
        sessionStartTime != nil
    }
}
