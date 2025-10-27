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
    
    private var lastGAD7Date: Date {
        get { lastGAD7DateTimestamp == 0 ? Date() : Date(timeIntervalSince1970: lastGAD7DateTimestamp) }
        set { lastGAD7DateTimestamp = newValue.timeIntervalSince1970 }
    }
    
    private var lastMoodDate: Date {
        get { lastMoodDateTimestamp == 0 ? Date(timeIntervalSince1970: 0) : Date(timeIntervalSince1970: lastMoodDateTimestamp) }
        set { lastMoodDateTimestamp = newValue.timeIntervalSince1970 }
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
    @State private var showNotificationPermission = false
    @State private var currentGreeting = ""
    @State private var showThankYou = false
    @State private var cardWidth: CGFloat = 0
    
    private let greetingMessages = [
        "You're stronger than you know", "Your feelings are valid and important", "Take a deep breath, you've got this",
        "It's okay to feel however you're feeling", "You're not alone in this journey", "Every small step counts",
        "Be gentle with yourself today", "You're worthy of peace and calm", "You're doing better than you think"
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
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 30) {
                        headerView
                        
                        gad7CardSection
                        
                        moodSection
                        
                        DailyTipView()
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 60)
                    .padding(.horizontal, 20)
                }
                .onAppear {
                    cardWidth = geometry.size.width - 40 // screen width minus padding
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
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowNotificationPermission"))) { _ in
            checkForNotificationPermission()
        }
        .sheet(isPresented: $showNotificationPermission) {
            NotificationPermissionView(
                onPermissionGranted: { print("✅ Granted") },
                onDismiss: { print("❌ Dismissed") }
            )
        }
    }

    // MARK: - Sections
    
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
                Text("Hi, \(userName) 👋")
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
            Text("Hi, \(userName) 👋")
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
            if !isMoodForToday {
                VStack(spacing: 20) {
                    Text("How do you feel right now?")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.themeText)
                    
                    MoodPickerView(selectedMood: $selectedMood) { expression in
                        HapticFeedback.light()
                        withAnimation(.easeInOut(duration: 0.5)) {
                            companionExpression = expression
                        }
                        saveMood()
                        withAnimation(.spring()) {
                            showThankYou = true
                        }
                    }
                    
                    if showThankYou {
                        Text("💜 Thank you for sharing how you feel today!")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.themeText.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .transition(.opacity.combined(with: .move(edge: .top)))
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
                showThankYou = true
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
