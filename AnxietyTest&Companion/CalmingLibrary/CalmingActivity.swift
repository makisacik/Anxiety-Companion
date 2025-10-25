//
//  CalmingActivity.swift
//  AnxietyTest&Companion
//
//  Defines the data model for each calming activity card.
//

import Foundation

struct CalmingActivity: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let emoji: String
    let description: String
    let colorHex: String
}
