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
    
    private let greetingMessages = [
        "You don’t have to be perfect to be enough",
        "It's okay to feel however you're feeling",
        "You're stronger than you know",
        "You're not alone in this journey",
        "Your feelings are valid and important",
        "Take a deep breath, you've got this",
        "Every small step counts",
        "Be gentle with yourself today",
        "You're worthy of peace and calm",
        "You're doing better than you think",
        "You deserve to rest and recharge",
        "Your emotions don’t define your worth",
        "You’ve handled hard days before — you can handle today too",
        "It’s okay to slow down and just be",
        "You are growing, even if it doesn’t feel like it",
        "You bring light to more people than you realize",
        "Peace begins with one gentle breath",
        "You are allowed to start over at any moment",
        "Healing takes time — and you’re already on your way",
        "Progress is still progress, no matter how small",
    ]

    
    private var buttonText: String {
        if hasCompletedTest || !gad7Entries.isEmpty {
            let daysAgo = Calendar.current.dateComponents([.day], from: lastGAD7Date, to: Date()).day ?? 0
            return daysAgo == 0 ? "Retake Test" : "Take Test"
        } else {
            return "Take Test"
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
            return "Good morning"
        case 12..<17:
            return "Hi"
        case 17..<21:
            return "Good evening"
        default:
            return "Good night"
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
                    Text("Start your calm minute 🌬️")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.themeText)
                    
                    Text(isBreathingForToday ? "You've breathed mindfully today 🌿" : "Take a moment to breathe and center yourself")
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
                    Text("Reflect for a moment ✍️")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.themeText)
                    
                    Text("Share your thoughts and feelings")
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
                    Text("Worry Tracker 💭")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.themeText)
                    
                    Text("Notice how worries change over time")
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
                    Text("Your Anxiety Check-In")
                        .font(.system(.title2, design: .serif))
                        .fontWeight(.semibold)
                        .foregroundColor(.themeText)
                    
                    if hasCompletedTest || !gad7Entries.isEmpty {
                        let daysAgo = Calendar.current.dateComponents([.day], from: lastGAD7Date, to: Date()).day ?? 0
                        let category = getScoreCategory(lastGAD7Score)
                        Text("Last test: \(daysAgo == 0 ? "Today" : "\(daysAgo) days ago") • Score: \(category) (\(lastGAD7Score)/21)")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.themeText.opacity(0.7))
                    } else {
                        Text("You haven't done a check-in yet.")
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
                        Text("How do you feel right now?")
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
                        Text("Thanks for sharing")
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
        currentGreeting = greetingMessages.randomElement() ?? "How are you feeling today?"
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
        case 0...4: return "Minimal"
        case 5...9: return "Mild"
        case 10...14: return "Moderate"
        default: return "Severe"
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
