//
//  AnxietyTestHomeView.swift
//  AnxietyTest&Companion
//
//  Created by Mehmet Ali Kısacık on 26.10.2025.
//

import SwiftUI
import CoreData
import Combine

struct AnxietyTestHomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("userName") private var userName = "Friend"
    @AppStorage("hasCompletedTest") private var hasCompletedTest = false
    @AppStorage("lastGAD7Score") private var lastGAD7Score = 0
    @AppStorage("lastGAD7DateTimestamp") private var lastGAD7DateTimestamp: Double = 0
    @AppStorage("lastMood") private var lastMood = -1 // default none
    @AppStorage("lastMoodDate") private var lastMoodDateTimestamp: Double = 0 // store mood date
    @AppStorage("lastBreathingDate") private var lastBreathingDateTimestamp: Double = 0 // track breathing date
    @AppStorage("lastReflectionDateTimestamp") private var lastReflectionDateTimestamp: Double = 0 // track reflection date
    
    private var lastGAD7Date: Date {
        get { lastGAD7DateTimestamp == 0 ? Date() : Date(timeIntervalSince1970: lastGAD7DateTimestamp) }
        set { lastGAD7DateTimestamp = newValue.timeIntervalSince1970 }
    }
    
    private var lastMoodDate: Date {
        get { lastMoodDateTimestamp == 0 ? Date(timeIntervalSince1970: 0) : Date(timeIntervalSince1970: lastMoodDateTimestamp) }
        set { lastMoodDateTimestamp = newValue.timeIntervalSince1970 }
    }
    
    private var lastBreathingDate: Date {
        get { lastBreathingDateTimestamp == 0 ? Date(timeIntervalSince1970: 0) : Date(timeIntervalSince1970: lastBreathingDateTimestamp) }
        set { lastBreathingDateTimestamp = newValue.timeIntervalSince1970 }
    }

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \GAD7Entry.date, ascending: false)],
        animation: .default
    ) private var gad7Entries: FetchedResults<GAD7Entry>

    @State private var companionExpression: CompanionFaceView.Expression = .neutral
    @State private var selectedMood: MoodPickerView.Mood? = nil
    @State private var showGreeting = false
    @State private var showTyping = false
    @State private var companionScale: CGFloat = 1.0
    @State private var showNotificationPermission = true
    @State private var currentGreeting = ""
    @State private var showThankYou = false
    @State private var cardWidth: CGFloat = 0
    
    private var greetingMessages: [String] {
        [
            String(localized: "home_companion_message_16"),
            String(localized: "home_companion_message_17"),
            String(localized: "home_companion_message_1"),
            String(localized: "home_companion_message_2"),
            String(localized: "home_companion_message_3"),
            String(localized: "home_companion_message_4"),
            String(localized: "home_companion_message_5"),
            String(localized: "home_companion_message_6"),
            String(localized: "home_companion_message_7"),
            String(localized: "home_companion_message_8"),
            String(localized: "home_companion_message_9"),
            String(localized: "home_companion_message_10"),
            String(localized: "home_companion_message_11"),
            String(localized: "home_companion_message_12"),
            String(localized: "home_companion_message_13"),
            String(localized: "home_companion_message_14"),
            String(localized: "home_companion_message_15"),
            String(localized: "home_companion_message_18"),
            String(localized: "home_companion_message_19"),
            String(localized: "home_companion_message_20")
        ]
    }

    
    private var buttonText: String {
        if hasCompletedTest || !gad7Entries.isEmpty {
            let daysAgo = Calendar.current.dateComponents([.day], from: lastGAD7Date, to: Date()).day ?? 0
            return daysAgo == 0 ? String(localized: "home_anxiety_retake_test") : String(localized: "home_anxiety_take_test")
        } else {
            return String(localized: "home_anxiety_take_test")
        }
    }
    
    private var isMoodForToday: Bool {
        Calendar.current.isDateInToday(lastMoodDate)
    }
    
    private var isBreathingForToday: Bool {
        Calendar.current.isDateInToday(lastBreathingDate)
    }
    
    private var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return String(localized: "home_greeting_good_morning")
        case 12..<17:
            return String(localized: "home_greeting_hi")
        case 17..<21:
            return String(localized: "home_greeting_good_evening")
        default:
            return String(localized: "home_greeting_good_night")
        }
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 30) {
                        headerView
                        
                        dailyBreathingCardSection
                        
                        dailyReflectionCardSection
                        
                        worryTrackerCardSection
                        
                        gad7CardSection
                        
                        moodSection
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 60)
                    .padding(.horizontal, 20)
                }
                .onChange(of: geometry.size.width) { newWidth in
                    cardWidth = newWidth - 40 // accounts for .horizontal padding
                }
                .task {
                    // fallback in case width is available after async layout
                    if cardWidth == 0 {
                        cardWidth = geometry.size.width - 40
                    }
                }
            }
            .background(
                ZStack {
                    Color.themeBackground
                        .ignoresSafeArea()
                    
                    // Tree footer as background decoration
                    VStack {
                        Spacer()
                        Image("tree-footer")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .opacity(0.3)
                    }
                    .ignoresSafeArea()
                }
            )
            .navigationTitle("")
        }
        .onAppear {
            selectRandomGreeting()
            loadLastMood()
            startGreetingAnimation()
            checkForNotificationPermission()
            // Evaluate notification scheduling (reflection, weekly test) under 72h cooldown
            ReminderScheduler.shared.evaluateAndScheduleIfNeeded()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowNotificationPermission"))) { _ in
            checkForNotificationPermission()
        }
        .overlay(
            NotificationPermissionView(
                isVisible: $showNotificationPermission,
                onPermissionGranted: { print("✅ Granted") },
                onDismiss: { print("❌ Dismissed") }
            )
        )
    }

    // MARK: - Sections
    
    private var dailyBreathingCardSection: some View {
        NavigationLink(destination: DailyBreathingView(onComplete: {
            lastBreathingDateTimestamp = Date().timeIntervalSince1970
        })) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: isBreathingForToday ? "checkmark.circle.fill" : "wind")
                    .font(.system(size: 32))
                    .foregroundColor(isBreathingForToday ? .green : .themeText)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(Color.themeBackground)
                    )
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(String(localized: "home_breathing_title"))
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.themeText)
                    
                    Text(isBreathingForToday ? String(localized: "home_breathing_completed") : String(localized: "home_breathing_prompt"))
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.themeText.opacity(0.7))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.themeText.opacity(0.5))
            }
            .padding(20)
            .frame(width: cardWidth > 0 ? cardWidth : nil)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.themeCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.themeDivider, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var dailyReflectionCardSection: some View {
        NavigationLink(destination: ReflectionView { savedDate in
            // Persist last reflection completion date for notification planning
            lastReflectionDateTimestamp = savedDate.timeIntervalSince1970
            // Re-evaluate scheduling with the new state
            ReminderScheduler.shared.evaluateAndScheduleIfNeeded()
        }) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: "pencil.line")
                    .font(.system(size: 32))
                    .foregroundColor(.themeText)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(Color.themeBackground)
                    )
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(String(localized: "home_reflection_title"))
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.themeText)
                    
                    Text(String(localized: "home_reflection_subtitle"))
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.themeText.opacity(0.7))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.themeText.opacity(0.5))
            }
            .padding(20)
            .frame(width: cardWidth > 0 ? cardWidth : nil)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.themeCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.themeDivider, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var worryTrackerCardSection: some View {
        NavigationLink(destination: WorryTrackerListView(context: viewContext)) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: "bubble.left.and.exclamationmark.bubble.right.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.themeText)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(Color.themeBackground)
                    )
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(String(localized: "home_worry_title"))
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.themeText)
                    
                    Text(String(localized: "home_worry_subtitle"))
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.themeText.opacity(0.7))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.themeText.opacity(0.5))
            }
            .padding(20)
            .frame(width: cardWidth > 0 ? cardWidth : nil)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.themeCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.themeDivider, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var headerView: some View {
        HStack(alignment: .center, spacing: 16) {
            // Companion on the left
            CompanionFaceView(expression: companionExpression)
                .frame(width: 100, height: 100)
                .scaleEffect(companionScale)
                .shadow(color: Color.themeText.opacity(0.15), radius: 10)
                .onTapGesture {
                    HapticFeedback.soft()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { companionScale = 1.1 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { companionScale = 1.0 }
                    }
                }
            
            // Text on the right
            VStack(alignment: .leading, spacing: 6) {
                Text("\(timeBasedGreeting), \(userName) 👋")
                    .font(.system(.title2, design: .serif))
                    .fontWeight(.semibold)
                    .foregroundColor(.themeText)
                    .opacity(showGreeting ? 1 : 0)
                    .offset(y: showGreeting ? 0 : 10)
                    .animation(.easeInOut(duration: 0.6), value: showGreeting)
                
                if showTyping {
                    TypingTextView(text: currentGreeting) { HapticFeedback.soft() }
                        .font(.system(.subheadline, design: .rounded))
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var greetingSection: some View {
        VStack(spacing: 8) {
            Text("\(timeBasedGreeting), \(userName) 👋")
                .font(.system(.title, design: .serif))
                .fontWeight(.semibold)
                .foregroundColor(.themeText)
                .opacity(showGreeting ? 1 : 0)
                .offset(y: showGreeting ? 0 : 10)
                .animation(.easeInOut(duration: 0.6), value: showGreeting)
            
            if showTyping {
                TypingTextView(text: currentGreeting) { HapticFeedback.soft() }
            }
        }
    }

    private var companionSection: some View {
        CompanionFaceView(expression: companionExpression)
            .scaleEffect(companionScale)
            .shadow(color: Color.themeText.opacity(0.15), radius: 10)
            .onTapGesture {
                HapticFeedback.soft()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { companionScale = 1.1 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { companionScale = 1.0 }
                }
            }
    }

    private var gad7CardSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "home_anxiety_checkin_title"))
                        .font(.system(.title2, design: .serif))
                        .fontWeight(.semibold)
                        .foregroundColor(.themeText)
                    
                    if hasCompletedTest || !gad7Entries.isEmpty {
                        let daysAgo = Calendar.current.dateComponents([.day], from: lastGAD7Date, to: Date()).day ?? 0
                        let category = getScoreCategory(lastGAD7Score)
                        let daysAgoText = daysAgo == 0 ? String(localized: "home_anxiety_last_test_today") : String.localizedStringWithFormat(String(localized: "home_anxiety_last_test_days_ago"), daysAgo)
                        Text(String.localizedStringWithFormat(String(localized: "home_anxiety_last_test_format"), daysAgoText, category, lastGAD7Score))
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.themeText.opacity(0.7))
                    } else {
                        Text(String(localized: "home_anxiety_last_test_none"))
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.themeText.opacity(0.7))
                    }
                }
                
                Spacer()
                if hasCompletedTest || !gad7Entries.isEmpty {
                    CircularProgressView(score: lastGAD7Score, maxScore: 21)
                }
            }
            
            NavigationLink(destination: GAD7TestView()) {
                Text(buttonText)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.themeBackgroundPure)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.themeText)
                    )
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(20)
        .frame(width: cardWidth > 0 ? cardWidth : nil)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.themeCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.themeDivider, lineWidth: 1)
                )
        )
    }

    private var moodSection: some View {
        Group {
            if !isMoodForToday || showThankYou {
                VStack(spacing: 20) {
                    if !showThankYou {
                        Text(String(localized: "home_mood_question"))
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.themeText)
                        
                        MoodPickerView(selectedMood: $selectedMood) { expression in
                            HapticFeedback.light()
                            withAnimation(.easeInOut(duration: 0.5)) {
                                companionExpression = expression
                            }
                            withAnimation(.spring()) {
                                showThankYou = true
                            }
                            // After 1.5s, first persist mood (which sets isMoodForToday=true),
                            // then animate the card out so the picker doesn't briefly reappear.
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                saveMood()
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showThankYou = false
                                }
                            }
                        }
                    } else {
                        Text(String(localized: "home_mood_thanks"))
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.themeText)
                            .transition(.opacity.combined(with: .scale))
                    }
                }
                .padding(20)
                .frame(width: cardWidth > 0 ? cardWidth : nil)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.themeCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.themeDivider, lineWidth: 1)
                        )
                )
                .transition(.opacity.combined(with: .scale))
            }
        }
    }

    // MARK: - Helpers
    
    private func selectRandomGreeting() {
        currentGreeting = greetingMessages.randomElement() ?? String(localized: "home_greeting_fallback")
    }

    private func startGreetingAnimation() {
        withAnimation(.easeInOut(duration: 0.6)) { showGreeting = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.6)) { showTyping = true }
        }
    }

    private func loadLastMood() {
        if Calendar.current.isDateInToday(lastMoodDate) {
            if lastMood >= 0, lastMood < MoodPickerView.Mood.allCases.count {
                selectedMood = MoodPickerView.Mood.allCases[lastMood]
                companionExpression = selectedMood?.companionExpression ?? .neutral
                // Don't show thank you on load - card should just be hidden
                showThankYou = false
            }
        } else {
            selectedMood = nil
            showThankYou = false
        }
    }

    private func saveMood() {
        if let mood = selectedMood,
           let index = MoodPickerView.Mood.allCases.firstIndex(of: mood) {
            lastMood = index
            lastMoodDateTimestamp = Date().timeIntervalSince1970
        }
    }

    private func checkForNotificationPermission() {
        let isFirstTestCompletion = UserDefaults.standard.bool(forKey: "isFirstTestCompletion")
        let reminderPromptShown = UserDefaults.standard.bool(forKey: "reminderPromptShown")

        if isFirstTestCompletion && !reminderPromptShown {
            UserDefaults.standard.set(false, forKey: "isFirstTestCompletion")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showNotificationPermission = true
            }
        }
    }

    private func getScoreCategory(_ score: Int) -> String {
        switch score {
        case 0...4: return String(localized: "home_anxiety_score_minimal")
        case 5...9: return String(localized: "home_anxiety_score_mild")
        case 10...14: return String(localized: "home_anxiety_score_moderate")
        default: return String(localized: "home_anxiety_score_severe")
        }
    }
}

// MARK: - Circular Progress View

struct CircularProgressView: View {
    let score: Int
    let maxScore: Int
    
    private var progress: Double {
        Double(score) / Double(maxScore)
    }
    
    private var progressColor: Color {
        switch score {
        case 0...4:
            return .green
        case 5...9:
            return .yellow
        case 10...14:
            return .orange
        default:
            return .red
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.themeDivider, lineWidth: 4)
                .frame(width: 50, height: 50)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(progressColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 50, height: 50)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
            
            Text("\(score)")
                .font(.system(.caption, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.themeText)
        }
    }
}
