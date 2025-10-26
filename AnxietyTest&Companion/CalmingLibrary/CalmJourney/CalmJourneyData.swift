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
                title: "Breathe & Ground",
                summary: "Learn to calm your body before your mind.",
                free: true,
                exercises: [
                    CalmExercise(
                        id: 1,
                        type: .education,
                        title: "What happens in anxiety",
                        instructions: [
                            "When you feel anxious, your body activates the fight-flight-freeze response.",
                            "Your heart races, muscles tense, and breathing becomes shallow.",
                            "This is your nervous system trying to protect you from perceived danger.",
                            "Learning to recognize and calm this response is the first step to managing anxiety."
                        ],
                        instructionPromptTypes: [
                            .statement,
                            .statement,
                            .statement,
                            .statement
                        ],
                        scienceNote: "Understanding the fight-flight-freeze response helps you recognize anxiety as a normal protective mechanism."
                    ),
                    CalmExercise(
                        id: 2,
                        type: .breathing,
                        title: "Box Breathing",
                        instructions: [
                            "Inhale for 4 seconds.",
                            "Hold your breath for 4 seconds.",
                            "Exhale for 4 seconds.",
                            "Hold again for 4 seconds.",
                            "Repeat for 1–2 minutes."
                        ],
                        instructionPromptTypes: [
                            .statement,
                            .action,
                            .action,
                            .action,
                            .action
                        ],
                        scienceNote: "Box breathing lowers heart rate and activates the parasympathetic nervous system."
                    ),
                    CalmExercise(
                        id: 3,
                        type: .prompt,
                        title: "Grounding 5-4-3-2-1",
                        instructions: [
                            "Name 5 things you can see.",
                            "Name 4 things you can touch.",
                            "Name 3 things you can hear.",
                            "Name 2 things you can smell.",
                            "Name 1 thing you can taste."
                        ],
                        instructionPromptTypes: [
                            .question,
                            .question,
                            .question,
                            .question,
                            .question
                        ],
                        scienceNote: "Grounding shifts attention from anxious thoughts to the present moment."
                    ),
                    CalmExercise(
                        id: 4,
                        type: .prompt,
                        title: "Body Scan",
                        instructions: [
                            "Take a deep breath.",
                            "Focus on your toes. Notice any tension.",
                            "Move your attention slowly up your legs.",
                            "Continue to your stomach, chest, shoulders, and face.",
                            "Release any tightness as you go."
                        ],
                        instructionPromptTypes: [
                            .action,
                            .statement,
                            .statement,
                            .statement,
                            .statement
                        ],
                        scienceNote: "Body scans increase interoceptive awareness and reduce muscle tension."
                    )
                ]
            ),
            
            // LEVEL 2 — Understand Anxiety (Premium)
            CalmLevel(
                id: 2,
                title: "Understand Anxiety",
                summary: "Learn why anxiety appears and how to interrupt the cycle.",
                free: false,
                exercises: [
                    CalmExercise(
                        id: 1,
                        type: .education,
                        title: "The Anxiety Loop",
                        instructions: [
                            "Anxiety starts with a perceived threat.",
                            "This triggers physical sensations (heart racing, tension).",
                            "You feel fear or worry and try to avoid the trigger.",
                            "Avoidance brings short relief but strengthens the anxiety cycle.",
                            "Awareness helps you break this loop."
                        ],
                        instructionPromptTypes: [
                            .statement,
                            .statement,
                            .statement,
                            .statement,
                            .statement
                        ],
                        scienceNote: "Understanding the anxiety feedback loop is a foundation of CBT."
                    ),
                    CalmExercise(
                        id: 2,
                        type: .prompt,
                        title: "Identify Triggers",
                        instructions: [
                            "Think of a recent time you felt anxious.",
                            "What was happening around you?",
                            "What did you do to cope?",
                            "Did the anxiety fade or grow afterward?"
                        ],
                        instructionPromptTypes: [
                            .question,
                            .question,
                            .question,
                            .question
                        ],
                        scienceNote: "Recognizing triggers builds control over automatic reactions."
                    ),
                    CalmExercise(
                        id: 3,
                        type: .prompt,
                        title: "Break the Loop",
                        instructions: [
                            "Imagine the same situation again.",
                            "What could you do differently next time?",
                            "Try small changes: breathing, staying present, or acting despite fear."
                        ],
                        instructionPromptTypes: [
                            .question,
                            .question,
                            .statement
                        ],
                        scienceNote: "Behavioral change interrupts avoidance and restores control."
                    )
                ]
            ),
            
            // LEVEL 3 — Thought Awareness (Premium)
            CalmLevel(
                id: 3,
                title: "Thought Awareness",
                summary: "Learn to observe and reframe anxious thoughts.",
                free: false,
                exercises: [
                    CalmExercise(
                        id: 1,
                        type: .education,
                        title: "Why Thoughts Matter",
                        instructions: [
                            "Our thoughts influence how we feel and act.",
                            "When anxious, we often believe our thoughts are facts.",
                            "Learning to question them can reduce anxiety."
                        ],
                        instructionPromptTypes: [
                            .statement,
                            .statement,
                            .statement
                        ],
                        scienceNote: "Cognitive restructuring reduces emotional reactivity."
                    ),
                    CalmExercise(
                        id: 2,
                        type: .prompt,
                        title: "Catch the Thought",
                        instructions: [
                            "Write down one anxious thought you've had recently.",
                            "Describe when it appeared and what you felt in your body."
                        ],
                        instructionPromptTypes: [
                            .question,
                            .question
                        ],
                        scienceNote: "Awareness is the first step toward change."
                    ),
                    CalmExercise(
                        id: 3,
                        type: .prompt,
                        title: "Check the Evidence",
                        instructions: [
                            "Ask yourself: What evidence supports this thought?",
                            "What evidence goes against it?",
                            "Is there another possible explanation?"
                        ],
                        instructionPromptTypes: [
                            .question,
                            .question,
                            .question
                        ],
                        scienceNote: "CBT teaches balanced thinking to counter distorted beliefs."
                    ),
                    CalmExercise(
                        id: 4,
                        type: .prompt,
                        title: "Reframe the Thought",
                        instructions: [
                            "Take your original thought and make it gentler.",
                            "Example: 'I can't handle this' → 'This is hard, but I've managed before.'",
                            "Notice how your body feels after reframing."
                        ],
                        instructionPromptTypes: [
                            .question,
                            .statement,
                            .question
                        ],
                        scienceNote: "Reframing reduces catastrophizing and promotes calm thinking."
                    )
                ]
            ),
            
            // LEVEL 4 — Build Calm Habits (Premium)
            CalmLevel(
                id: 4,
                title: "Build Calm Habits",
                summary: "Create small routines that support mental balance.",
                free: false,
                exercises: [
                    CalmExercise(
                        id: 1,
                        type: .education,
                        title: "Habits and Mood",
                        instructions: [
                            "Regular routines reduce uncertainty.",
                            "Even small activities like walking or journaling can improve mood.",
                            "Structure supports emotional stability."
                        ],
                        instructionPromptTypes: [
                            .statement,
                            .statement,
                            .statement
                        ],
                        scienceNote: "Behavioral activation increases positive reinforcement and reduces anxiety."
                    ),
                    CalmExercise(
                        id: 2,
                        type: .prompt,
                        title: "Identify Calm Habits",
                        instructions: [
                            "What daily habit helps you feel calm?",
                            "It could be a walk, music, journaling, or talking to a friend."
                        ],
                        instructionPromptTypes: [
                            .question,
                            .statement
                        ],
                        scienceNote: "Linking calm behaviors to routine strengthens emotional regulation."
                    ),
                    CalmExercise(
                        id: 3,
                        type: .prompt,
                        title: "Plan a Small Action",
                        instructions: [
                            "Choose one small calm action for today.",
                            "Set a specific time you'll do it.",
                            "Later, reflect on how it felt."
                        ],
                        instructionPromptTypes: [
                            .question,
                            .question,
                            .question
                        ],
                        scienceNote: "Small achievable goals build momentum and confidence."
                    )
                ]
            ),
            
            // LEVEL 5 — Compassion & Maintenance (Premium)
            CalmLevel(
                id: 5,
                title: "Compassion & Maintenance",
                summary: "Learn to be kind to yourself and maintain balance.",
                free: false,
                exercises: [
                    CalmExercise(
                        id: 1,
                        type: .education,
                        title: "Why Self-Compassion Matters",
                        instructions: [
                            "Anxiety often comes with self-criticism.",
                            "Treating yourself with kindness reduces shame and fear.",
                            "Self-compassion is strength, not weakness."
                        ],
                        instructionPromptTypes: [
                            .statement,
                            .statement,
                            .statement
                        ],
                        scienceNote: "Self-compassion improves resilience and emotion regulation."
                    ),
                    CalmExercise(
                        id: 2,
                        type: .prompt,
                        title: "Self-Compassion Check",
                        instructions: [
                            "Think of a moment you felt anxious or embarrassed.",
                            "What did you tell yourself?",
                            "What would you say to a close friend in the same situation?"
                        ],
                        instructionPromptTypes: [
                            .question,
                            .question,
                            .question
                        ],
                        scienceNote: "Reframing self-talk promotes emotional healing."
                    ),
                    CalmExercise(
                        id: 3,
                        type: .prompt,
                        title: "Values Reflection",
                        instructions: [
                            "What truly matters to you that anxiety sometimes gets in the way of?",
                            "What small step can you take toward it anyway?"
                        ],
                        instructionPromptTypes: [
                            .question,
                            .question
                        ],
                        scienceNote: "Acting on values builds long-term emotional balance."
                    ),
                    CalmExercise(
                        id: 4,
                        type: .prompt,
                        title: "Calm Reminder Note",
                        instructions: [
                            "Write a message to your future self for hard moments.",
                            "Example: 'Breathe. You've handled harder days before.'"
                        ],
                        instructionPromptTypes: [
                            .question,
                            .statement
                        ],
                        scienceNote: "Personal affirmations reinforce emotional safety."
                    )
                ]
            )
        ]
    }
}
