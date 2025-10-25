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

    func markActivityCompleted(_ activity: CalmingActivity) {
        lastCompletedActivityID = activity.id
        UserDefaults.standard.set(Date(), forKey: "lastCalmCompletionDate")
    }

    var lastCompletionDate: Date? {
        UserDefaults.standard.object(forKey: "lastCalmCompletionDate") as? Date
    }
}
