//
//  CalmingActivity.swift
//  AnxietyTest&Companion
//
//  Defines the data model for each calming activity card.
//

import Foundation

enum CalmingActivityType: String {
    case breathing = "breathing"
    case grounding = "grounding"
    case journaling = "journaling"
    case gratitude = "gratitude"
    case affirmation = "affirmation"
}

struct CalmingActivity: Identifiable, Hashable {
    let id = UUID()
    let type: CalmingActivityType
    let title: String
    let emoji: String
    let description: String
    let colorHex: String
}
