//
//  CalmingActivityStore.swift
//  AnxietyTest&Companion
//
//  Provides a static list of calming activities for offline use.
//

import Foundation

final class CalmingActivityStore {
    static let shared = CalmingActivityStore()

    private init() {}

    var activities: [CalmingActivity] {
        [
            CalmingActivity(
                type: .breathing,
                title: String(localized: "activity_breathing_title"),
                emoji: "🌬️",
                description: String(localized: "activity_breathing_desc"),
                colorHex: "#A5C4E3"
            ),
            CalmingActivity(
                type: .grounding,
                title: String(localized: "activity_grounding_title"),
                emoji: "🌍",
                description: String(localized: "activity_grounding_desc"),
                colorHex: "#EED9A2"
            ),
            CalmingActivity(
                type: .journaling,
                title: String(localized: "activity_journaling_title"),
                emoji: "🖊️",
                description: String(localized: "activity_journaling_desc"),
                colorHex: "#D0B3E3"
            ),
            CalmingActivity(
                type: .gratitude,
                title: String(localized: "activity_gratitude_title"),
                emoji: "🌤️",
                description: String(localized: "activity_gratitude_desc"),
                colorHex: "#F9E79F"
            ),
            CalmingActivity(
                type: .affirmation,
                title: String(localized: "activity_affirmation_title"),
                emoji: "🌸",
                description: String(localized: "activity_affirmation_desc"),
                colorHex: "#F6C1C1"
            )
        ]
    }
}
