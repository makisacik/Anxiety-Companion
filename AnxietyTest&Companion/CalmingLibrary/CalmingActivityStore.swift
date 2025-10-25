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

    let activities: [CalmingActivity] = [
        CalmingActivity(title: "Breathing", emoji: "🌬️",
                        description: "Inhale for 4, hold 2, exhale for 4.",
                        colorHex: "#A5C4E3"),
        CalmingActivity(title: "Grounding", emoji: "🌍",
                        description: "Name 3 things you can see right now.",
                        colorHex: "#EED9A2"),
        CalmingActivity(title: "Journaling", emoji: "🖊️",
                        description: "Write one thought that's been looping in your mind.",
                        colorHex: "#D0B3E3"),
        CalmingActivity(title: "Gratitude", emoji: "🌤️",
                        description: "Think of one small thing that made you smile today.",
                        colorHex: "#F9E79F"),
        CalmingActivity(title: "Affirmation", emoji: "🌸",
                        description: "Say this aloud: 'I'm allowed to take things slow.'",
                        colorHex: "#F6C1C1")
    ]
}
