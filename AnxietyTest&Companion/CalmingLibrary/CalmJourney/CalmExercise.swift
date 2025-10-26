//
//  CalmExercise.swift
//  AnxietyTest&Companion
//
//  Defines the data model for individual exercises within Calm Journey levels.
//

import Foundation

enum ExerciseType: String, CaseIterable, Codable {
    case breathing = "breathing"
    case prompt = "prompt"
    case education = "education"
}

struct CalmExercise: Identifiable, Codable, Hashable {
    let id: Int
    let type: ExerciseType
    let title: String
    let instructions: [String]
    let scienceNote: String
    
    var displayType: String {
        switch type {
        case .breathing:
            return "Breathing Exercise"
        case .prompt:
            return "Reflection Prompt"
        case .education:
            return "Learn"
        }
    }
    
    var icon: String {
        switch type {
        case .breathing:
            return "lungs.fill"
        case .prompt:
            return "pencil.and.outline"
        case .education:
            return "brain.head.profile"
        }
    }
}
