//
//  SettingsView.swift
//  AnxietyTest&Companion
//
//  Created by Mehmet Ali Kısacık on 26.10.2025.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("isPremiumUser") private var isPremiumUser = false
    @State private var actualNotificationStatus: Bool = false
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.themeBackground
                    .ignoresSafeArea(.all)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Settings")
                                .font(.system(.largeTitle, design: .serif))
                                .fontWeight(.bold)
                                .foregroundColor(.themeText)
                            
                            Text("Customize your experience")
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(.themeText.opacity(0.7))
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                        
                        // Reminders Section
                        VStack(spacing: 20) {
                            // Section Header
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.themeText)
                                    .font(.system(size: 20))
                                
                                Text("Reminders")
                                    .font(.system(.title2, design: .serif))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.themeText)
                                
                                Spacer()
                            }
                            
                            // Reminder Toggle Card
                            VStack(spacing: 16) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Gentle Check-ins")
                                            .font(.system(.headline, design: .rounded))
                                            .foregroundColor(.themeText)
                                        
                                        Text("Get gentle reminders to check in on your wellbeing every few days")
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundColor(.themeText.opacity(0.7))
                                            .multilineTextAlignment(.leading)
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $notificationsEnabled)
                                        .toggleStyle(SwitchToggleStyle(tint: Color.themeText))
                                        .onChange(of: notificationsEnabled) { newValue in
                                            handleToggleChange(newValue)
                                        }
                                }
                                
                                // Status indicator
                                if !isLoading {
                                    HStack {
                                        Image(systemName: actualNotificationStatus ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                            .foregroundColor(actualNotificationStatus ? .green : .orange)
                                        
                                        Text(statusText)
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundColor(.themeText.opacity(0.7))
                                        
                                        Spacer()
                                    }
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.themeCard)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.themeDivider, lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Development Settings
                        VStack(spacing: 20) {
                            HStack {
                                Image(systemName: "gearshape.fill")
                                    .foregroundColor(.themeText)
                                    .font(.system(size: 20))
                                
                                Text("Development")
                                    .font(.system(.title2, design: .serif))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.themeText)
                                
                                Spacer()
                            }
                            
                            VStack(spacing: 12) {
                                // Premium Toggle for Testing
                                VStack(spacing: 16) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Premium Access")
                                                .font(.system(.headline, design: .rounded))
                                                .foregroundColor(.themeText)

                                            Text("Unlock all Calm Journey levels for testing")
                                                .font(.system(.caption, design: .rounded))
                                                .foregroundColor(.themeText.opacity(0.7))
                                                .multilineTextAlignment(.leading)
                                        }

                                        Spacer()

                                        Toggle("", isOn: $isPremiumUser)
                                            .toggleStyle(SwitchToggleStyle(tint: Color.themeText))
                                    }
                                }
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.themeCard)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.themeDivider, lineWidth: 1)
                                        )
                                )

                                SettingsRow(
                                    icon: "clock.fill",
                                    title: "Reminder Frequency",
                                    subtitle: "Customize how often you get reminders",
                                    isEnabled: false
                                )
                                
                                SettingsRow(
                                    icon: "message.fill",
                                    title: "Message Customization",
                                    subtitle: "Personalize your reminder messages",
                                    isEnabled: false
                                )
                                
                                // Reset Mood Button
                                Button(action: {
                                    resetMoodForToday()
                                }) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "arrow.counterclockwise.circle.fill")
                                            .foregroundColor(.themeText)
                                            .font(.system(size: 18))
                                            .frame(width: 24)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Reset Today's Mood")
                                                .font(.system(.body, design: .rounded))
                                                .fontWeight(.medium)
                                                .foregroundColor(.themeText)
                                            
                                            Text("Clear today's mood selection for testing")
                                                .font(.system(.caption, design: .rounded))
                                                .foregroundColor(.themeText.opacity(0.7))
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.themeText.opacity(0.4))
                                            .font(.system(size: 12))
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.themeCard)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.themeDivider, lineWidth: 1)
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Debug button for filling test data
                                Button(action: {
                                    fillDebugData()
                                }) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "wand.and.stars")
                                            .foregroundColor(.themeText)
                                            .font(.system(size: 18))
                                            .frame(width: 24)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Fill Debug Data")
                                                .font(.system(.body, design: .rounded))
                                                .fontWeight(.medium)
                                                .foregroundColor(.themeText)
                                            
                                            Text("Fill user data with realistic anxious responses for testing")
                                                .font(.system(.caption, design: .rounded))
                                                .foregroundColor(.themeText.opacity(0.7))
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.themeText.opacity(0.4))
                                            .font(.system(size: 12))
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.themeCard)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.themeDivider, lineWidth: 1)
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 60)
                    }
                }
            }
        }
        .onAppear {
            checkNotificationStatus()
        }
    }
    
    private var statusText: String {
        if notificationsEnabled && actualNotificationStatus {
            return "Reminders are active and working"
        } else if notificationsEnabled && !actualNotificationStatus {
            return "Reminders are off — enable them in iOS Settings 🌿"
        } else {
            return "Reminders are disabled"
        }
    }
    
    private func checkNotificationStatus() {
        isLoading = true
        ReminderScheduler.shared.checkAuthorizationStatus { status in
            DispatchQueue.main.async {
                actualNotificationStatus = status
                isLoading = false
            }
        }
    }
    
    private func handleToggleChange(_ isEnabled: Bool) {
        HapticFeedback.light()
        
        if isEnabled {
            // Enable reminders
            ReminderScheduler.shared.requestAuthorization { granted in
                DispatchQueue.main.async {
                    if granted {
                        actualNotificationStatus = true
                        HapticFeedback.success()
                    } else {
                        notificationsEnabled = false
                        actualNotificationStatus = false
                        HapticFeedback.warning()
                    }
                }
            }
        } else {
            // Disable reminders
            ReminderScheduler.shared.cancelReminders()
            actualNotificationStatus = false
        }
    }
    
    private func resetMoodForToday() {
        HapticFeedback.light()
        UserDefaults.standard.set(-1, forKey: "lastMood")
        UserDefaults.standard.set(0.0, forKey: "lastMoodDate")
        HapticFeedback.success()
    }
    
    private func fillDebugData() {
        HapticFeedback.light()
        
        // Clear existing data first
        let context = DataManager.shared.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ExerciseResponse")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Error clearing existing data: \(error)")
        }
        
        // Fill with realistic anxious person responses
        let debugResponses: [(levelId: Int, exerciseId: Int, title: String, instruction: String, response: String)] = [
            // Level 1 - Awareness
            (1, 1, "Body Scan", "Notice what you feel in your body right now", "I feel tightness in my chest and my shoulders are really tense. My heart is racing and I can't seem to relax. Everything feels overwhelming."),
            (1, 2, "Breathing Awareness", "Take three deep breaths and notice how you feel", "I'm trying to breathe but it feels shallow. My mind keeps racing with worries about work and I can't focus on just breathing."),
            
            // Level 2 - Grounding
            (2, 3, "5-4-3-2-1 Grounding", "Name 5 things you can see, 4 you can touch, 3 you can hear, 2 you can smell, 1 you can taste", "I see my messy desk, my phone, the window, my coffee cup, and my laptop. I can touch my desk, my phone, my coffee cup, and my sweater. I hear traffic outside, my computer fan, and my own breathing. I smell coffee and something stale. I taste the coffee I just drank. This actually helped a little."),
            (2, 4, "Progressive Muscle Relaxation", "Tense and release each muscle group", "I tried to tense my muscles but I'm already so tense that it's hard to tell the difference. When I released, I felt a tiny bit of relief in my shoulders."),
            
            // Level 3 - Reframing
            (3, 5, "Thought Challenge", "Write down a worry and challenge it with evidence", "I'm worried I'll mess up my presentation tomorrow. Evidence against: I've prepared well, my boss said I'm doing good work, and even if I make a mistake, it's not the end of the world. I'm being too hard on myself."),
            (3, 6, "Gratitude Practice", "Write down three things you're grateful for", "I'm grateful for my supportive friend who listened to me yesterday, for having a roof over my head, and for my cat who always makes me smile even when I'm anxious."),
            
            // Level 4 - Self-Compassion
            (4, 7, "Self-Compassion Break", "What would you say to a friend in your situation?", "If my friend was feeling this anxious, I'd tell them it's okay to feel this way, that anxiety is normal, and that they're doing their best. I'd remind them of their strengths and that this feeling will pass. I should be kinder to myself."),
            (4, 8, "Loving-Kindness Meditation", "Send kind thoughts to yourself and others", "May I be safe and free from suffering. May I be happy and at peace. May I be healthy and strong. I'm trying to be more compassionate with myself, even when I feel anxious."),
            
            // Level 5 - Compassion & Maintenance
            (5, 9, "Daily Check-in", "How are you feeling today and what do you need?", "Today I'm feeling anxious about the meeting later, but I'm also proud that I did my breathing exercises this morning. I need to remember to be patient with myself and not expect perfection."),
            (5, 10, "Progress Reflection", "What progress have you made in managing anxiety?", "I've learned to recognize when I'm getting anxious earlier, and I'm using the grounding techniques more often. I'm still struggling with negative thoughts, but I'm getting better at challenging them. I'm proud of myself for sticking with this."),
            
            // Level 6 - Resilience
            (6, 11, "Coping Strategy Review", "What strategies work best for you?", "Deep breathing helps when I catch it early, but when I'm really panicked, the 5-4-3-2-1 grounding works better. I also find that calling a friend or going for a walk helps me reset."),
            (6, 12, "Stress Response Awareness", "Notice how your body responds to stress", "When I'm stressed, my chest gets tight, my hands shake, and I start overthinking everything. I'm learning to recognize these signs earlier and use my coping strategies before it gets too bad."),
            
            // Level 7 - Mindfulness
            (7, 13, "Present Moment Awareness", "Focus on what's happening right now", "Right now I'm sitting at my desk, I can hear the rain outside, and I'm feeling a bit calmer than I was earlier. I'm trying to stay present instead of worrying about tomorrow."),
            (7, 14, "Mindful Observation", "Observe your thoughts without judgment", "I notice I'm having thoughts about being judged at work, but I'm trying to just observe them without getting caught up in them. They're just thoughts, not facts."),
            
            // Level 8 - Emotional Intelligence
            (8, 15, "Emotion Identification", "Name the emotions you're feeling right now", "I'm feeling anxious, frustrated, and a little hopeful. The anxiety is about the presentation, frustration because I wish I wasn't so anxious, and hopeful because I'm learning to manage it better."),
            (8, 16, "Emotion Regulation", "How can you respond to these emotions constructively?", "Instead of fighting the anxiety, I can acknowledge it and use my breathing techniques. I can remind myself that it's okay to feel this way and that I have tools to help me through it."),
            
            // Level 9 - Social Connection
            (9, 17, "Support System Reflection", "Who can you reach out to for support?", "I can call my sister who always makes me laugh, or text my friend who understands anxiety. I also have my therapist appointment next week. I don't have to go through this alone."),
            (9, 18, "Communication Practice", "How can you express your needs to others?", "I can tell my boss that I need a few minutes to prepare before the presentation. I can ask my friend to just listen without trying to fix everything. I'm learning that it's okay to ask for what I need."),
            
            // Level 10 - Growth & Purpose
            (10, 19, "Values Clarification", "What values are most important to you?", "I value kindness, authenticity, and growth. I want to be kind to myself and others, be authentic about my struggles, and keep growing and learning. These values help guide me when I'm feeling lost."),
            (10, 20, "Future Vision", "What do you want your relationship with anxiety to look like?", "I want to see anxiety as a signal rather than a threat. I want to have tools to manage it and not let it control my life. I want to be compassionate with myself when I struggle and celebrate my progress."),
        ]
        
        // Save all debug responses
        for response in debugResponses {
            DataManager.shared.saveExerciseResponse(
                levelId: response.levelId,
                exerciseId: response.exerciseId,
                exerciseTitle: response.title,
                instructionText: response.instruction,
                userResponse: response.response,
                includeInReport: true,
                completedAt: Date().addingTimeInterval(-Double.random(in: 0...86400 * 7)) // Random time within last week
            )
        }
        
        // Mark levels as completed using the same format as the save function
        let completedLevelsArray = Array(1...10)
        if let data = try? JSONEncoder().encode(completedLevelsArray) {
            UserDefaults.standard.set(data, forKey: "completedLevels")
            print("Debug: Set completed levels to: \(completedLevelsArray) (encoded)")
        } else {
            print("Debug: Failed to encode completed levels")
        }
        
        // Post notification to refresh views
        NotificationCenter.default.post(name: NSNotification.Name("DebugDataFilled"), object: nil)
        
        HapticFeedback.success()
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let isEnabled: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(isEnabled ? .themeText : Color.themeText.opacity(0.4))
                .font(.system(size: 18))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(isEnabled ? .themeText : .themeText.opacity(0.6))
                
                Text(subtitle)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.themeText.opacity(0.5))
            }
            
            Spacer()
            
            if !isEnabled {
                Text("Coming Soon")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.themeText.opacity(0.4))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.themeDivider.opacity(0.3))
                    )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.themeCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.themeDivider, lineWidth: 1)
                )
        )
    }
}

#Preview {
    SettingsView()
}

#Preview {
    SettingsView()
}
