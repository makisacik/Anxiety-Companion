//
//  CalmJourneyData.swift
//  AnxietyTest&Companion
//
//  Static data store for all Calm Journey levels and exercises.
//

import Foundation
import Combine

class CalmJourneyDataStore: ObservableObject {
    static let shared = CalmJourneyDataStore()
    
    @Published var levels: [CalmLevel]
    
    private init() {
        self.levels = CalmJourneyDataStore.createLevels()
    }
    
    private static func createLevels() -> [CalmLevel] {
        return [
            // LEVEL 1 — Breathe & Ground (Free)
            CalmLevel(
                id: 1,
                title: String(localized: "journey_level_1_title"),
                summary: String(localized: "journey_level_1_summary"),
                free: true,
                exercises: [
                    CalmExercise(
                        id: 1,
                        type: .education,
                        title: String(localized: "journey_level_1_exercise_1_title"),
                        instructions: [
                            String(localized: "journey_level_1_exercise_1_instruction_0"),
                            String(localized: "journey_level_1_exercise_1_instruction_1"),
                            String(localized: "journey_level_1_exercise_1_instruction_2"),
                            String(localized: "journey_level_1_exercise_1_instruction_3")
                        ],
                        instructionPromptTypes: [
                            .statement,
                            .statement,
                            .statement,
                            .statement
                        ],
                        scienceNote: String(localized: "journey_level_1_exercise_1_science"),
                        reportValue: .exclude,
                        imageNames: ["afraid", "afraid", "shadow-monster", "thinking-bulb"]
                    ),
                    CalmExercise(
                        id: 2,
                        type: .breathing,
                        title: String(localized: "journey_level_1_exercise_2_title"),
                        instructions: [
                            String(localized: "journey_level_1_exercise_2_instruction_0"),
                            String(localized: "journey_level_1_exercise_2_instruction_1"),
                            String(localized: "journey_level_1_exercise_2_instruction_2"),
                            String(localized: "journey_level_1_exercise_2_instruction_3"),
                            String(localized: "journey_level_1_exercise_2_instruction_4")
                        ],
                        instructionPromptTypes: [
                            .statement,
                            .action,
                            .action,
                            .action,
                            .action
                        ],
                        scienceNote: String(localized: "journey_level_1_exercise_2_science"),
                        reportValue: .exclude,
                        imageNames: []
                    ),
                    CalmExercise(
                        id: 3,
                        type: .grounding,
                        title: String(localized: "journey_level_1_exercise_3_title"),
                        instructions: [
                            String(localized: "journey_level_1_exercise_3_instruction_0"),
                            String(localized: "journey_level_1_exercise_3_instruction_1"),
                            String(localized: "journey_level_1_exercise_3_instruction_2"),
                            String(localized: "journey_level_1_exercise_3_instruction_3"),
                            String(localized: "journey_level_1_exercise_3_instruction_4")
                        ],
                        instructionPromptTypes: [
                            .question,
                            .question,
                            .question,
                            .question,
                            .question
                        ],
                        scienceNote: String(localized: "journey_level_1_exercise_3_science"),
                        reportValue: .exclude,
                        imageNames: []
                    ),
                    CalmExercise(
                        id: 4,
                        type: .relaxBody,
                        title: String(localized: "journey_level_1_exercise_4_title"),
                        instructions: [
                            String(localized: "journey_level_1_exercise_4_instruction_0")
                        ],
                        instructionPromptTypes: [
                            .statement
                        ],
                        scienceNote: String(localized: "journey_level_1_exercise_4_science"),
                        reportValue: .exclude,
                        imageNames: []
                    )
                ]
            ),
            
            // LEVEL 2 — Understand Anxiety (Premium)
            CalmLevel(
                id: 2,
                title: String(localized: "journey_level_2_title"),
                summary: String(localized: "journey_level_2_summary"),
                free: false,
                exercises: [
                    CalmExercise(
                        id: 1,
                        type: .education,
                        title: String(localized: "journey_level_2_exercise_1_title"),
                        instructions: [
                            String(localized: "journey_level_2_exercise_1_instruction_0"),
                            String(localized: "journey_level_2_exercise_1_instruction_1"),
                            String(localized: "journey_level_2_exercise_1_instruction_2"),
                            String(localized: "journey_level_2_exercise_1_instruction_3"),
                            String(localized: "journey_level_2_exercise_1_instruction_4")
                        ],
                        instructionPromptTypes: [
                            .statement,
                            .statement,
                            .statement,
                            .statement,
                            .statement
                        ],
                        scienceNote: String(localized: "journey_level_2_exercise_1_science"),
                        reportValue: .exclude,
                        imageNames: ["shadow-monster", "afraid", "inside-box-sad", "cutting-branch", "break-egg"]
                    ),
                    CalmExercise(
                        id: 2,
                        type: .prompt,
                        title: String(localized: "journey_level_2_exercise_2_title"),
                        instructions: [
                            String(localized: "journey_level_2_exercise_2_instruction_0"),
                            String(localized: "journey_level_2_exercise_2_instruction_1"),
                            String(localized: "journey_level_2_exercise_2_instruction_2"),
                            String(localized: "journey_level_2_exercise_2_instruction_3")
                        ],
                        instructionPromptTypes: [
                            .question,
                            .question,
                            .question,
                            .question
                        ],
                        scienceNote: String(localized: "journey_level_2_exercise_2_science"),
                        reportValue: .include,
                        imageNames: []
                    ),
                    CalmExercise(
                        id: 3,
                        type: .prompt,
                        title: String(localized: "journey_level_2_exercise_3_title"),
                        instructions: [
                            String(localized: "journey_level_2_exercise_3_instruction_0"),
                            String(localized: "journey_level_2_exercise_3_instruction_1"),
                            String(localized: "journey_level_2_exercise_3_instruction_2")
                        ],
                        instructionPromptTypes: [
                            .statement,
                            .question,
                            .statement
                        ],
                        scienceNote: String(localized: "journey_level_2_exercise_3_science"),
                        reportValue: .include,
                        imageNames: []
                    )
                ]
            ),
            
            // LEVEL 3 — Thought Awareness (Premium)
            CalmLevel(
                id: 3,
                title: String(localized: "journey_level_3_title"),
                summary: String(localized: "journey_level_3_summary"),
                free: false,
                exercises: [
                    CalmExercise(
                        id: 1,
                        type: .education,
                        title: String(localized: "journey_level_3_exercise_1_title"),
                        instructions: [
                            String(localized: "journey_level_3_exercise_1_instruction_0"),
                            String(localized: "journey_level_3_exercise_1_instruction_1"),
                            String(localized: "journey_level_3_exercise_1_instruction_2")
                        ],
                        instructionPromptTypes: [
                            .statement,
                            .statement,
                            .statement
                        ],
                        scienceNote: String(localized: "journey_level_3_exercise_1_science"),
                        reportValue: .exclude,
                        imageNames: ["thinking-bubble", "thinking-1", "question-hand"]
                    ),
                    CalmExercise(
                        id: 2,
                        type: .prompt,
                        title: String(localized: "journey_level_3_exercise_2_title"),
                        instructions: [
                            String(localized: "journey_level_3_exercise_2_instruction_0"),
                            String(localized: "journey_level_3_exercise_2_instruction_1")
                        ],
                        instructionPromptTypes: [
                            .question,
                            .question
                        ],
                        scienceNote: String(localized: "journey_level_3_exercise_2_science"),
                        reportValue: .include,
                        imageNames: []
                    ),
                    CalmExercise(
                        id: 3,
                        type: .prompt,
                        title: String(localized: "journey_level_3_exercise_3_title"),
                        instructions: [
                            String(localized: "journey_level_3_exercise_3_instruction_0"),
                            String(localized: "journey_level_3_exercise_3_instruction_1"),
                            String(localized: "journey_level_3_exercise_3_instruction_2")
                        ],
                        instructionPromptTypes: [
                            .question,
                            .question,
                            .question
                        ],
                        scienceNote: String(localized: "journey_level_3_exercise_3_science"),
                        reportValue: .include,
                        imageNames: []
                    ),
                    CalmExercise(
                        id: 4,
                        type: .prompt,
                        title: String(localized: "journey_level_3_exercise_4_title"),
                        instructions: [
                            String(localized: "journey_level_3_exercise_4_instruction_0"),
                            String(localized: "journey_level_3_exercise_4_instruction_1"),
                            String(localized: "journey_level_3_exercise_4_instruction_2")
                        ],
                        instructionPromptTypes: [
                            .question,
                            .statement,
                            .question
                        ],
                        scienceNote: String(localized: "journey_level_3_exercise_4_science"),
                        reportValue: .include,
                        imageNames: []
                    )
                ]
            ),
            
            // LEVEL 4 — Build Calm Habits (Premium)
            CalmLevel(
                id: 4,
                title: String(localized: "journey_level_4_title"),
                summary: String(localized: "journey_level_4_summary"),
                free: false,
                exercises: [
                    CalmExercise(
                        id: 1,
                        type: .education,
                        title: String(localized: "journey_level_4_exercise_1_title"),
                        instructions: [
                            String(localized: "journey_level_4_exercise_1_instruction_0"),
                            String(localized: "journey_level_4_exercise_1_instruction_1"),
                            String(localized: "journey_level_4_exercise_1_instruction_2")
                        ],
                        instructionPromptTypes: [
                            .statement,
                            .statement,
                            .statement
                        ],
                        scienceNote: String(localized: "journey_level_4_exercise_1_science"),
                        reportValue: .exclude,
                        imageNames: ["thinking-bulb", "walking-up", "hands-open-smile"]
                    ),
                    CalmExercise(
                        id: 2,
                        type: .prompt,
                        title: String(localized: "journey_level_4_exercise_2_title"),
                        instructions: [
                            String(localized: "journey_level_4_exercise_2_instruction_0"),
                            String(localized: "journey_level_4_exercise_2_instruction_1")
                        ],
                        instructionPromptTypes: [
                            .question,
                            .statement
                        ],
                        scienceNote: String(localized: "journey_level_4_exercise_2_science"),
                        reportValue: .include,
                        imageNames: []
                    ),
                    CalmExercise(
                        id: 3,
                        type: .prompt,
                        title: String(localized: "journey_level_4_exercise_3_title"),
                        instructions: [
                            String(localized: "journey_level_4_exercise_3_instruction_0"),
                            String(localized: "journey_level_4_exercise_3_instruction_1"),
                            String(localized: "journey_level_4_exercise_3_instruction_2")
                        ],
                        instructionPromptTypes: [
                            .question,
                            .question,
                            .question
                        ],
                        scienceNote: String(localized: "journey_level_4_exercise_3_science"),
                        reportValue: .include,
                        imageNames: []
                    )
                ]
            ),
            
            // LEVEL 5 — Compassion & Maintenance (Premium)
            CalmLevel(
                id: 5,
                title: String(localized: "journey_level_5_title"),
                summary: String(localized: "journey_level_5_summary"),
                free: false,
                exercises: [
                    CalmExercise(
                        id: 1,
                        type: .education,
                        title: String(localized: "journey_level_5_exercise_1_title"),
                        instructions: [
                            String(localized: "journey_level_5_exercise_1_instruction_0"),
                            String(localized: "journey_level_5_exercise_1_instruction_1"),
                            String(localized: "journey_level_5_exercise_1_instruction_2")
                        ],
                        instructionPromptTypes: [
                            .statement,
                            .statement,
                            .statement
                        ],
                        scienceNote: String(localized: "journey_level_5_exercise_1_science"),
                        reportValue: .exclude,
                        imageNames: ["inside-box-sad", "hands-open-smile", "shadow-angel"]
                    ),
                    CalmExercise(
                        id: 2,
                        type: .prompt,
                        title: String(localized: "journey_level_5_exercise_2_title"),
                        instructions: [
                            String(localized: "journey_level_5_exercise_2_instruction_0"),
                            String(localized: "journey_level_5_exercise_2_instruction_1"),
                            String(localized: "journey_level_5_exercise_2_instruction_2")
                        ],
                        instructionPromptTypes: [
                            .question,
                            .question,
                            .question
                        ],
                        scienceNote: String(localized: "journey_level_5_exercise_2_science"),
                        reportValue: .include,
                        imageNames: []
                    ),
                    CalmExercise(
                        id: 3,
                        type: .prompt,
                        title: String(localized: "journey_level_5_exercise_3_title"),
                        instructions: [
                            String(localized: "journey_level_5_exercise_3_instruction_0"),
                            String(localized: "journey_level_5_exercise_3_instruction_1")
                        ],
                        instructionPromptTypes: [
                            .question,
                            .question
                        ],
                        scienceNote: String(localized: "journey_level_5_exercise_3_science"),
                        reportValue: .include,
                        imageNames: []
                    ),
                    CalmExercise(
                        id: 4,
                        type: .prompt,
                        title: String(localized: "journey_level_5_exercise_4_title"),
                        instructions: [
                            String(localized: "journey_level_5_exercise_4_instruction_0"),
                            String(localized: "journey_level_5_exercise_4_instruction_1")
                        ],
                        instructionPromptTypes: [
                            .question,
                            .statement
                        ],
                        scienceNote: String(localized: "journey_level_5_exercise_4_science"),
                        reportValue: .include,
                        imageNames: []
                    )
                ]
            ),

            // LEVEL 6 — Facing Fears Gently (Premium)
            CalmLevel(
                id: 6,
                title: String(localized: "journey_level_6_title"),
                summary: String(localized: "journey_level_6_summary"),
                free: false,
                exercises: [
                    CalmExercise(
                        id: 6,
                        type: .education,
                        title: String(localized: "journey_level_6_exercise_6_title"),
                        instructions: [
                            String(localized: "journey_level_6_exercise_6_instruction_0"),
                            String(localized: "journey_level_6_exercise_6_instruction_1"),
                            String(localized: "journey_level_6_exercise_6_instruction_2")
                        ],
                        instructionPromptTypes: [.statement, .statement, .statement],
                        scienceNote: String(localized: "journey_level_6_exercise_6_science"),
                        reportValue: .exclude,
                        imageNames: ["afraid", "inside-box-sad", "shadow-hero"]
                    ),
                    CalmExercise(
                        id: 7,
                        type: .prompt,
                        title: String(localized: "journey_level_6_exercise_7_title"),
                        instructions: [
                            String(localized: "journey_level_6_exercise_7_instruction_0"),
                            String(localized: "journey_level_6_exercise_7_instruction_1"),
                            String(localized: "journey_level_6_exercise_7_instruction_2")
                        ],
                        instructionPromptTypes: [.question, .question, .question],
                        scienceNote: String(localized: "journey_level_6_exercise_7_science"),
                        reportValue: .include,
                        imageNames: []
                    ),
                    CalmExercise(
                        id: 8,
                        type: .prompt,
                        title: String(localized: "journey_level_6_exercise_8_title"),
                        instructions: [
                            String(localized: "journey_level_6_exercise_8_instruction_0"),
                            String(localized: "journey_level_6_exercise_8_instruction_1")
                        ],
                        instructionPromptTypes: [.question, .question],
                        scienceNote: String(localized: "journey_level_6_exercise_8_science"),
                        reportValue: .include,
                        imageNames: []
                    ),
                    CalmExercise(
                        id: 9,
                        type: .breathing,
                        title: String(localized: "journey_level_6_exercise_9_title"),
                        instructions: [
                            String(localized: "journey_level_6_exercise_9_instruction_0"),
                            String(localized: "journey_level_6_exercise_9_instruction_1"),
                            String(localized: "journey_level_6_exercise_9_instruction_2")
                        ],
                        instructionPromptTypes: [.action, .action, .statement],
                        scienceNote: String(localized: "journey_level_6_exercise_9_science"),
                        reportValue: .exclude,
                        imageNames: []
                    )
                ]
            ),

            // LEVEL 7 — Mindful Presence (Premium)
            CalmLevel(
                id: 7,
                title: String(localized: "journey_level_7_title"),
                summary: String(localized: "journey_level_7_summary"),
                free: false,
                exercises: [
                    CalmExercise(
                        id: 10,
                        type: .education,
                        title: String(localized: "journey_level_7_exercise_10_title"),
                        instructions: [
                            String(localized: "journey_level_7_exercise_10_instruction_0"),
                            String(localized: "journey_level_7_exercise_10_instruction_1"),
                            String(localized: "journey_level_7_exercise_10_instruction_2")
                        ],
                        instructionPromptTypes: [.statement, .statement, .statement],
                        scienceNote: String(localized: "journey_level_7_exercise_10_science"),
                        reportValue: .exclude,
                        imageNames: ["meditate-1", "thinking-1", "hands-open-smile"]
                    ),
                    CalmExercise(
                        id: 11,
                        type: .breathing,
                        title: String(localized: "journey_level_7_exercise_11_title"),
                        instructions: [
                            String(localized: "journey_level_7_exercise_11_instruction_0"),
                            String(localized: "journey_level_7_exercise_11_instruction_1"),
                            String(localized: "journey_level_7_exercise_11_instruction_2"),
                            String(localized: "journey_level_7_exercise_11_instruction_3")
                        ],
                        instructionPromptTypes: [.action, .action, .action, .statement],
                        scienceNote: String(localized: "journey_level_7_exercise_11_science"),
                        reportValue: .exclude,
                        imageNames: []
                    ),
                    CalmExercise(
                        id: 12,
                        type: .prompt,
                        title: String(localized: "journey_level_7_exercise_12_title"),
                        instructions: [
                            String(localized: "journey_level_7_exercise_12_instruction_0"),
                            String(localized: "journey_level_7_exercise_12_instruction_1"),
                            String(localized: "journey_level_7_exercise_12_instruction_2")
                        ],
                        instructionPromptTypes: [.question, .question, .question],
                        scienceNote: String(localized: "journey_level_7_exercise_12_science"),
                        reportValue: .include,
                        imageNames: []
                    )
                ]
            ),

            // LEVEL 8 — Emotional Balance (Premium)
            CalmLevel(
                id: 8,
                title: String(localized: "journey_level_8_title"),
                summary: String(localized: "journey_level_8_summary"),
                free: false,
                exercises: [
                    CalmExercise(
                        id: 13,
                        type: .education,
                        title: String(localized: "journey_level_8_exercise_13_title"),
                        instructions: [
                            String(localized: "journey_level_8_exercise_13_instruction_0"),
                            String(localized: "journey_level_8_exercise_13_instruction_1"),
                            String(localized: "journey_level_8_exercise_13_instruction_2")
                        ],
                        instructionPromptTypes: [.statement, .statement, .statement],
                        scienceNote: String(localized: "journey_level_8_exercise_13_science"),
                        reportValue: .exclude,
                        imageNames: ["thinking-bubble", "kung-fu", "meditate-1"]
                    ),
                    CalmExercise(
                        id: 14,
                        type: .prompt,
                        title: String(localized: "journey_level_8_exercise_14_title"),
                        instructions: [
                            String(localized: "journey_level_8_exercise_14_instruction_0"),
                            String(localized: "journey_level_8_exercise_14_instruction_1"),
                            String(localized: "journey_level_8_exercise_14_instruction_2")
                        ],
                        instructionPromptTypes: [.question, .question, .question],
                        scienceNote: String(localized: "journey_level_8_exercise_14_science"),
                        reportValue: .include,
                        imageNames: []
                    ),
                    CalmExercise(
                        id: 15,
                        type: .prompt,
                        title: String(localized: "journey_level_8_exercise_15_title"),
                        instructions: [
                            String(localized: "journey_level_8_exercise_15_instruction_0"),
                            String(localized: "journey_level_8_exercise_15_instruction_1"),
                            String(localized: "journey_level_8_exercise_15_instruction_2")
                        ],
                        instructionPromptTypes: [.action, .question, .question],
                        scienceNote: String(localized: "journey_level_8_exercise_15_science"),
                        reportValue: .include,
                        imageNames: []
                    )
                ]
            ),

            // LEVEL 9 — Connection & Support (Premium)
            CalmLevel(
                id: 9,
                title: String(localized: "journey_level_9_title"),
                summary: String(localized: "journey_level_9_summary"),
                free: false,
                exercises: [
                    CalmExercise(
                        id: 16,
                        type: .education,
                        title: String(localized: "journey_level_9_exercise_16_title"),
                        instructions: [
                            String(localized: "journey_level_9_exercise_16_instruction_0"),
                            String(localized: "journey_level_9_exercise_16_instruction_1"),
                            String(localized: "journey_level_9_exercise_16_instruction_2")
                        ],
                        instructionPromptTypes: [.statement, .statement, .statement],
                        scienceNote: String(localized: "journey_level_9_exercise_16_science"),
                        reportValue: .exclude,
                        imageNames: ["brain-handshake", "hands-open-smile", "shadow-angel"]
                    ),
                    CalmExercise(
                        id: 17,
                        type: .prompt,
                        title: String(localized: "journey_level_9_exercise_17_title"),
                        instructions: [
                            String(localized: "journey_level_9_exercise_17_instruction_0"),
                            String(localized: "journey_level_9_exercise_17_instruction_1")
                        ],
                        instructionPromptTypes: [.question, .question],
                        scienceNote: String(localized: "journey_level_9_exercise_17_science"),
                        reportValue: .include,
                        imageNames: []
                    ),
                    CalmExercise(
                        id: 18,
                        type: .prompt,
                        title: String(localized: "journey_level_9_exercise_18_title"),
                        instructions: [
                            String(localized: "journey_level_9_exercise_18_instruction_0"),
                            String(localized: "journey_level_9_exercise_18_instruction_1"),
                            String(localized: "journey_level_9_exercise_18_instruction_2")
                        ],
                        instructionPromptTypes: [.question, .action, .question],
                        scienceNote: String(localized: "journey_level_9_exercise_18_science"),
                        reportValue: .include,
                        imageNames: []
                    )
                ]
            ),

            // LEVEL 10 — Growth & Purpose (Premium)
            CalmLevel(
                id: 10,
                title: String(localized: "journey_level_10_title"),
                summary: String(localized: "journey_level_10_summary"),
                free: false,
                exercises: [
                    CalmExercise(
                        id: 19,
                        type: .education,
                        title: String(localized: "journey_level_10_exercise_19_title"),
                        instructions: [
                            String(localized: "journey_level_10_exercise_19_instruction_0"),
                            String(localized: "journey_level_10_exercise_19_instruction_1"),
                            String(localized: "journey_level_10_exercise_19_instruction_2")
                        ],
                        instructionPromptTypes: [.statement, .statement, .statement],
                        scienceNote: String(localized: "journey_level_10_exercise_19_science"),
                        reportValue: .exclude,
                        imageNames: ["walking-up", "hands-open-smile", "thinking-bulb"]
                    ),
                    CalmExercise(
                        id: 20,
                        type: .prompt,
                        title: String(localized: "journey_level_10_exercise_20_title"),
                        instructions: [
                            String(localized: "journey_level_10_exercise_20_instruction_0"),
                            String(localized: "journey_level_10_exercise_20_instruction_1")
                        ],
                        instructionPromptTypes: [.question, .statement],
                        scienceNote: String(localized: "journey_level_10_exercise_20_science"),
                        reportValue: .include,
                        imageNames: []
                    ),
                    CalmExercise(
                        id: 21,
                        type: .prompt,
                        title: String(localized: "journey_level_10_exercise_21_title"),
                        instructions: [
                            String(localized: "journey_level_10_exercise_21_instruction_0"),
                            String(localized: "journey_level_10_exercise_21_instruction_1"),
                            String(localized: "journey_level_10_exercise_21_instruction_2")
                        ],
                        instructionPromptTypes: [.question, .question, .question],
                        scienceNote: String(localized: "journey_level_10_exercise_21_science"),
                        reportValue: .include,
                        imageNames: []
                    ),
                    CalmExercise(
                        id: 22,
                        type: .prompt,
                        title: String(localized: "journey_level_10_exercise_22_title"),
                        instructions: [
                            String(localized: "journey_level_10_exercise_22_instruction_0"),
                            String(localized: "journey_level_10_exercise_22_instruction_1")
                        ],
                        instructionPromptTypes: [.question, .question],
                        scienceNote: String(localized: "journey_level_10_exercise_22_science"),
                        reportValue: .include,
                        imageNames: []
                    )
                ]
            )
        ]
    }
}
