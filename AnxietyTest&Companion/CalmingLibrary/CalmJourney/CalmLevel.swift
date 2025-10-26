//
//  CalmLevel.swift
//  AnxietyTest&Companion
//
//  Defines the data model for Calm Journey levels.
//

import Foundation

struct CalmLevel: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let summary: String
    let free: Bool
    let exercises: [CalmExercise]
    
    var isLocked: Bool {
        return !free
    }
    
    var lockIcon: String {
        return isLocked ? "lock.fill" : "checkmark.circle.fill"
    }
    
    var completionPercentage: Double {
        // This will be calculated based on completed exercises
        return 0.0
    }
}
