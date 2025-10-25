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
    @AppStorage("lastGAD7Date") private var lastGAD7Date = Date()
    @AppStorage("lastMood") private var lastMood = 0
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \GAD7Entry.date, ascending: false)],
        animation: .default
    )
    private var gad7Entries: FetchedResults<GAD7Entry>

    @State private var companionExpression: CompanionFaceView.Expression = .neutral
    @State private var selectedMood: MoodPickerView.Mood? = nil
    @State private var showGreeting = false
    @State private var showTyping = false
    @State private var companionScale: CGFloat = 1.0
    @State private var showNotificationPermission = false

    private var buttonText: String {
        if hasCompletedTest || !gad7Entries.isEmpty {
            let daysAgo = Calendar.current.dateComponents([.day], from: lastGAD7Date, to: Date()).day ?? 0
            return daysAgo == 0 ? "Retake Test" : "Take Test"
        } else {
            return "Take Test"
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Greeting Section
                    greetingSection
                    
                    // Companion Bubble
                    companionSection
                    
                    // GAD-7 Check-in Card
                    gad7CardSection
                    
                    // Mood Quick Check
                    moodSection
                    
                    // Daily Tip
                    DailyTipView()
                        .padding(.horizontal, 20)
                }
                .padding(.top, 40)
                .padding(.bottom, 60)
            }
            .background(
                LinearGradient(
                    colors: [Color(hex: "#6E63A4"), Color(hex: "#B5A7E0")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
        }
        .onAppear {
            loadLastMood()
            startGreetingAnimation()
            checkForNotificationPermission()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowNotificationPermission"))) { _ in
            checkForNotificationPermission()
        }
        .sheet(isPresented: $showNotificationPermission) {
            NotificationPermissionView(
                onPermissionGranted: {
                    print("User granted notification permission")
                },
                onDismiss: {
                    print("User dismissed notification permission")
                }
            )
        }
    }
    
    private var greetingSection: some View {
        VStack(spacing: 16) {
            Text("Hi, \(userName) 👋")
                .font(.system(.title, design: .serif))
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .opacity(showGreeting ? 1 : 0)
                .offset(y: showGreeting ? 0 : 10)
                .animation(.easeInOut(duration: 0.6), value: showGreeting)
            
            if showTyping {
                TypingTextView(text: "How are you feeling today?") {
                    HapticFeedback.soft()
                }
            }
        }
        .padding(.horizontal, 40)
    }
    
    private var companionSection: some View {
        CompanionFaceView(expression: companionExpression)
            .scaleEffect(companionScale)
            .shadow(color: Color.white.opacity(0.25), radius: 10, x: 0, y: 5)
            .onTapGesture {
                HapticFeedback.soft()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    companionScale = 1.1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        companionScale = 1.0
                    }
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
                        .foregroundColor(.white)
                    
                    if hasCompletedTest || !gad7Entries.isEmpty {
                        let daysAgo = Calendar.current.dateComponents([.day], from: lastGAD7Date, to: Date()).day ?? 0
                        let category = getScoreCategory(lastGAD7Score)
                        Text("Last test: \(daysAgo == 0 ? "Today" : "\(daysAgo) days ago") • Score: \(category) (\(lastGAD7Score)/21)")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    } else {
                        Text("You haven't done a check-in yet.")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
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
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color(hex: "#B5A7E0"))
                    )
            }
            .buttonStyle(ScaleButtonStyle())
            .simultaneousGesture(
                TapGesture()
                    .onEnded {
                        HapticFeedback.success()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            companionExpression = .happy
                        }
                    }
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
    
    private var moodSection: some View {
        VStack(spacing: 20) {
            Text("How do you feel right now?")
                .font(.system(.headline, design: .rounded))
                .foregroundColor(.white)
            
            MoodPickerView(selectedMood: $selectedMood) { expression in
                HapticFeedback.light()
                withAnimation(.easeInOut(duration: 0.5)) {
                    companionExpression = expression
                }
                saveMood()
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func startGreetingAnimation() {
        withAnimation(.easeInOut(duration: 0.6)) {
            showGreeting = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.6)) {
                showTyping = true
            }
        }
    }
    
    private func loadLastMood() {
        if lastMood >= 0 && lastMood < MoodPickerView.Mood.allCases.count {
            selectedMood = MoodPickerView.Mood.allCases[lastMood]
            companionExpression = selectedMood?.companionExpression ?? .neutral
        }
    }
    
    private func saveMood() {
        if let mood = selectedMood,
           let index = MoodPickerView.Mood.allCases.firstIndex(of: mood) {
            lastMood = index
        }
    }
    
    private func checkForNotificationPermission() {
        // Check if user just completed their first test and we haven't shown the permission prompt yet
        let isFirstTestCompletion = UserDefaults.standard.bool(forKey: "isFirstTestCompletion")
        let reminderPromptShown = UserDefaults.standard.bool(forKey: "reminderPromptShown")
        
        print("🔔 Notification Permission Check:")
        print("   - isFirstTestCompletion: \(isFirstTestCompletion)")
        print("   - reminderPromptShown: \(reminderPromptShown)")
        
        if isFirstTestCompletion && !reminderPromptShown {
            print("   - ✅ Showing notification permission sheet")
            // Clear the first test completion flag
            UserDefaults.standard.set(false, forKey: "isFirstTestCompletion")
            
            // Show notification permission after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showNotificationPermission = true
            }
        } else {
            print("   - ❌ Not showing notification permission sheet")
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

struct CircularProgressView: View {
    let score: Int
    let maxScore: Int
    
    private var progress: Double {
        Double(score) / Double(maxScore)
    }
    
    private var color: Color {
        switch score {
        case 0...4: return .green
        case 5...9: return .yellow
        case 10...14: return .orange
        default: return .red
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 4)
                .frame(width: 40, height: 40)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 40, height: 40)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: progress)
            
            Text("\(score)")
                .font(.system(.caption, design: .rounded))
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    AnxietyTestHomeView()
}
