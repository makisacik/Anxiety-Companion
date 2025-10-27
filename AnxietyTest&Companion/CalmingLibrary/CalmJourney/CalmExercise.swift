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

enum ReportValue: String, CaseIterable, Codable {
    case include = "include"
    case exclude = "exclude"
}

struct CalmExercise: Identifiable, Codable, Hashable {
    let id: Int
    let type: ExerciseType
    let title: String
    let instructions: [String]
    let instructionPromptTypes: [InstructionPromptType]
    let scienceNote: String
    let reportValue: ReportValue
    let imageNames: [String?]  // One image per instruction
    
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

// Represents the type of instruction prompt
enum InstructionPromptType: String, CaseIterable, Codable {
    case statement = "statement"      // Just information/instruction, no user input needed
    case question = "question"        // Requires user text input
    case action = "action"           // User needs to perform an action (like breathing)
}

// Represents an individual instruction step for the page-by-page flow
struct InstructionStep: Identifiable {
    let id: Int
    let instruction: String
    let exerciseType: ExerciseType
    let exerciseTitle: String
    let exerciseId: Int
    let promptType: InstructionPromptType
    let imageName: String?

    // Computed property for backward compatibility
    var isQuestion: Bool {
        return promptType == .question
    }

    init(id: Int, instruction: String, exerciseType: ExerciseType, exerciseTitle: String, exerciseId: Int, promptType: InstructionPromptType, imageName: String? = nil) {
        self.id = id
        self.instruction = instruction
        self.exerciseType = exerciseType
        self.exerciseTitle = exerciseTitle
        self.exerciseId = exerciseId
        self.promptType = promptType
        self.imageName = imageName
    }
}
