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
                        scienceNote: "Understanding the fight-flight-freeze response helps you recognize anxiety as a normal protective mechanism.",
                        reportValue: .exclude,
                        imageNames: ["afraid", "afraid", "shadow-monster", "thinking-bulb"]
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
                        scienceNote: "Box breathing lowers heart rate and activates the parasympathetic nervous system.",
                        reportValue: .exclude,
                        imageNames: []
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
                        scienceNote: "Grounding shifts attention from anxious thoughts to the present moment.",
                        reportValue: .exclude,
                        imageNames: []
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
                        scienceNote: "Body scans increase interoceptive awareness and reduce muscle tension.",
                        reportValue: .exclude,
                        imageNames: []
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
                        scienceNote: "Understanding the anxiety feedback loop is a foundation of CBT.",
                        reportValue: .exclude,
                        imageNames: ["shadow-monster", "afraid", "inside-box-sad", "cutting-branch", "break-egg"]
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
                        scienceNote: "Recognizing triggers builds control over automatic reactions.",
                        reportValue: .include,
                        imageNames: []
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
                        scienceNote: "Behavioral change interrupts avoidance and restores control.",
                        reportValue: .include,
                        imageNames: []
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
                        scienceNote: "Cognitive restructuring reduces emotional reactivity.",
                        reportValue: .exclude,
                        imageNames: ["thinking-bubble", "thinking-1", "question-hand"]
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
                        scienceNote: "Awareness is the first step toward change.",
                        reportValue: .include,
                        imageNames: []
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
                        scienceNote: "CBT teaches balanced thinking to counter distorted beliefs.",
                        reportValue: .include,
                        imageNames: []
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
                        scienceNote: "Reframing reduces catastrophizing and promotes calm thinking.",
                        reportValue: .include,
                        imageNames: []
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
                        scienceNote: "Behavioral activation increases positive reinforcement and reduces anxiety.",
                        reportValue: .exclude,
                        imageNames: ["thinking-bulb", "walking-up", "hands-open-smile"]
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
                        scienceNote: "Linking calm behaviors to routine strengthens emotional regulation.",
                        reportValue: .include,
                        imageNames: []
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
                        scienceNote: "Small achievable goals build momentum and confidence.",
                        reportValue: .include,
                        imageNames: []
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
                        scienceNote: "Self-compassion improves resilience and emotion regulation.",
                        reportValue: .exclude,
                        imageNames: ["inside-box-sad", "hands-open-smile", "shadow-angel"]
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
                        scienceNote: "Reframing self-talk promotes emotional healing.",
                        reportValue: .include,
                        imageNames: []
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
                        scienceNote: "Acting on values builds long-term emotional balance.",
                        reportValue: .include,
                        imageNames: []
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
                        scienceNote: "Personal affirmations reinforce emotional safety.",
                        reportValue: .include,
                        imageNames: []
                    )
                ]
            ),

            // LEVEL 6 — Facing Fears Gently (Premium)
            CalmLevel(
                id: 6,
                title: "Facing Fears Gently",
                summary: "Build courage through small, safe steps toward feared situations.",
                free: false,
                exercises: [
                    CalmExercise(
                        id: 6,
                        type: .education,
                        title: "Understanding Fear",
                        instructions: [
                            "Fear is your body's alarm system, designed to keep you safe.",
                            "When the alarm goes off too often, it can limit your life.",
                            "Facing fear gently teaches your brain that safety can exist even in discomfort."
                        ],
                        instructionPromptTypes: [.statement, .statement, .statement],
                        scienceNote: "Gradual exposure reduces avoidance and rewires fear pathways.",
                        reportValue: .exclude,
                        imageNames: ["afraid", "inside-box-sad", "shadow-hero"]
                    ),
                    CalmExercise(
                        id: 7,
                        type: .prompt,
                        title: "Your Fear Ladder",
                        instructions: [
                            "List three things that make you anxious: one mild, one moderate, one strong.",
                            "Choose one small fear to face safely this week.",
                            "Imagine how it might feel afterward."
                        ],
                        instructionPromptTypes: [.question, .question, .question],
                        scienceNote: "Breaking fears into small steps increases confidence and control.",
                        reportValue: .include,
                        imageNames: []
                    ),
                    CalmExercise(
                        id: 8,
                        type: .prompt,
                        title: "Reflect on Courage",
                        instructions: [
                            "Recall a time you faced something scary and it went better than expected.",
                            "What helped you stay grounded in that moment?"
                        ],
                        instructionPromptTypes: [.question, .question],
                        scienceNote: "Remembering success reinforces self-efficacy and calm.",
                        reportValue: .include,
                        imageNames: []
                    ),
                    CalmExercise(
                        id: 9,
                        type: .breathing,
                        title: "Calm Before Action",
                        instructions: [
                            "Before approaching a fear, pause and breathe slowly for 10 seconds.",
                            "Inhale gently through the nose, exhale through the mouth.",
                            "Remind yourself: 'I can do this step calmly.'"
                        ],
                        instructionPromptTypes: [.action, .action, .statement],
                        scienceNote: "Pre-exposure breathing reduces physiological arousal.",
                        reportValue: .exclude,
                        imageNames: []
                    )
                ]
            ),

            // LEVEL 7 — Mindful Presence (Premium)
            CalmLevel(
                id: 7,
                title: "Mindful Presence",
                summary: "Learn to stay grounded in the present moment.",
                free: false,
                exercises: [
                    CalmExercise(
                        id: 10,
                        type: .education,
                        title: "What Is Mindfulness?",
                        instructions: [
                            "Mindfulness means paying attention to now, without judging it.",
                            "It helps you notice thoughts and sensations rather than reacting to them.",
                            "Calm often arises when awareness replaces resistance."
                        ],
                        instructionPromptTypes: [.statement, .statement, .statement],
                        scienceNote: "Mindfulness reduces rumination and increases emotional regulation.",
                        reportValue: .exclude,
                        imageNames: ["meditate-1", "thinking-1", "hands-open-smile"]
                    ),
                    CalmExercise(
                        id: 11,
                        type: .breathing,
                        title: "Five-Minute Presence",
                        instructions: [
                            "Set a timer for five minutes.",
                            "Focus on your breath as it moves in and out.",
                            "When your mind wanders, gently bring it back to the breath.",
                            "Notice sensations, sounds, and the space around you."
                        ],
                        instructionPromptTypes: [.action, .action, .action, .statement],
                        scienceNote: "Brief mindfulness practice activates the parasympathetic system.",
                        reportValue: .exclude,
                        imageNames: []
                    ),
                    CalmExercise(
                        id: 12,
                        type: .prompt,
                        title: "Observe Without Fixing",
                        instructions: [
                            "Recall a recent difficult emotion.",
                            "Write what it felt like in your body without labeling it good or bad.",
                            "What happened when you simply observed it?"
                        ],
                        instructionPromptTypes: [.question, .question, .question],
                        scienceNote: "Non-judgmental observation decreases emotional reactivity.",
                        reportValue: .include,
                        imageNames: []
                    )
                ]
            ),

            // LEVEL 8 — Emotional Balance (Premium)
            CalmLevel(
                id: 8,
                title: "Emotional Balance",
                summary: "Understand and regulate emotions with compassion.",
                free: false,
                exercises: [
                    CalmExercise(
                        id: 13,
                        type: .education,
                        title: "Riding Emotional Waves",
                        instructions: [
                            "Emotions rise and fall like waves.",
                            "Trying to block them often makes them stronger.",
                            "Riding the wave means allowing the feeling until it naturally fades."
                        ],
                        instructionPromptTypes: [.statement, .statement, .statement],
                        scienceNote: "Emotion regulation involves acceptance rather than suppression.",
                        reportValue: .exclude,
                        imageNames: ["thinking-bubble", "kung-fu", "meditate-1"]
                    ),
                    CalmExercise(
                        id: 14,
                        type: .prompt,
                        title: "Name the Feeling",
                        instructions: [
                            "Think of something that upset you recently.",
                            "Label the main emotion as precisely as you can.",
                            "Where do you feel it in your body?"
                        ],
                        instructionPromptTypes: [.question, .question, .question],
                        scienceNote: "Labeling emotions activates prefrontal control and reduces intensity.",
                        reportValue: .include,
                        imageNames: []
                    ),
                    CalmExercise(
                        id: 15,
                        type: .prompt,
                        title: "Pause Practice",
                        instructions: [
                            "When a strong emotion appears, take one slow breath.",
                            "Ask: 'What do I need right now — to act or to rest?'",
                            "Write a short reflection afterward."
                        ],
                        instructionPromptTypes: [.action, .question, .question],
                        scienceNote: "The pause between emotion and reaction builds emotional mastery.",
                        reportValue: .include,
                        imageNames: []
                    )
                ]
            ),

            // LEVEL 9 — Connection & Support (Premium)
            CalmLevel(
                id: 9,
                title: "Connection & Support",
                summary: "Strengthen bonds and find safety in connection.",
                free: false,
                exercises: [
                    CalmExercise(
                        id: 16,
                        type: .education,
                        title: "Why Connection Calms",
                        instructions: [
                            "Humans regulate emotions through relationships.",
                            "Sharing stress with someone safe can lower your cortisol levels.",
                            "Connection turns isolation into safety."
                        ],
                        instructionPromptTypes: [.statement, .statement, .statement],
                        scienceNote: "Co-regulation is a proven buffer against anxiety.",
                        reportValue: .exclude,
                        imageNames: ["brain-handshake", "hands-open-smile", "shadow-angel"]
                    ),
                    CalmExercise(
                        id: 17,
                        type: .prompt,
                        title: "Safe People Map",
                        instructions: [
                            "List three people who make you feel calm or supported.",
                            "What qualities make them feel safe to you?"
                        ],
                        instructionPromptTypes: [.question, .question],
                        scienceNote: "Identifying supportive figures increases perceived safety.",
                        reportValue: .include,
                        imageNames: []
                    ),
                    CalmExercise(
                        id: 18,
                        type: .prompt,
                        title: "Reach Out",
                        instructions: [
                            "Think of someone you haven't spoken to in a while but trust.",
                            "Send a short message or plan a brief chat.",
                            "Afterward, reflect on how it felt to connect."
                        ],
                        instructionPromptTypes: [.question, .action, .question],
                        scienceNote: "Positive social contact boosts oxytocin and reduces anxiety.",
                        reportValue: .include,
                        imageNames: []
                    )
                ]
            ),

            // LEVEL 10 — Growth & Purpose (Premium)
            CalmLevel(
                id: 10,
                title: "Growth & Purpose",
                summary: "Integrate calm into daily life and long-term meaning.",
                free: false,
                exercises: [
                    CalmExercise(
                        id: 19,
                        type: .education,
                        title: "Your Calm Journey",
                        instructions: [
                            "Every calm skill you've learned is part of a larger growth story.",
                            "Progress is not perfection — it's presence, patience, and practice.",
                            "Let's look at what this growth means to you."
                        ],
                        instructionPromptTypes: [.statement, .statement, .statement],
                        scienceNote: "Reflecting on progress consolidates learning and motivation.",
                        reportValue: .exclude,
                        imageNames: ["walking-up", "hands-open-smile", "thinking-bulb"]
                    ),
                    CalmExercise(
                        id: 20,
                        type: .prompt,
                        title: "Letter to Future You",
                        instructions: [
                            "Write a short message to your future self for when anxiety returns.",
                            "Include words of encouragement and a reminder of your strengths."
                        ],
                        instructionPromptTypes: [.question, .statement],
                        scienceNote: "Self-directed compassion strengthens resilience over time.",
                        reportValue: .include,
                        imageNames: []
                    ),
                    CalmExercise(
                        id: 21,
                        type: .prompt,
                        title: "Purpose Compass",
                        instructions: [
                            "What matters most to you beyond anxiety?",
                            "What small daily action aligns with that value?",
                            "How could you make calm part of your purpose?"
                        ],
                        instructionPromptTypes: [.question, .question, .question],
                        scienceNote: "Values-based living supports long-term emotional stability.",
                        reportValue: .include,
                        imageNames: []
                    ),
                    CalmExercise(
                        id: 22,
                        type: .prompt,
                        title: "Gratitude Grounding",
                        instructions: [
                            "List three things you're grateful for today.",
                            "Notice how your body feels when focusing on gratitude."
                        ],
                        instructionPromptTypes: [.question, .question],
                        scienceNote: "Gratitude practices increase positive affect and reduce anxiety symptoms.",
                        reportValue: .include,
                        imageNames: []
                    )
                ]
            )
        ]
    }
}
