//
//  GAD7TestView.swift
//  AnxietyTest&Companion
//
//  Created by Mehmet Ali Kısacık on 26.10.2025.
//

import SwiftUI
import CoreData

struct GAD7TestView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("hasCompletedTest") private var hasCompletedTest = false
    @AppStorage("lastGAD7Score") private var lastGAD7Score = 0
    @AppStorage("lastGAD7DateTimestamp") private var lastGAD7DateTimestamp: Double = 0

    private var lastGAD7Date: Date {
        get {
            lastGAD7DateTimestamp == 0 ? Date() : Date(timeIntervalSince1970: lastGAD7DateTimestamp)
        }
        set {
            lastGAD7DateTimestamp = newValue.timeIntervalSince1970
        }
    }
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \GAD7Entry.date, ascending: false)],
        animation: .default
    )
    private var gad7Entries: FetchedResults<GAD7Entry>

    @State private var currentQuestion = 0
    @State private var answers: [Int] = Array(repeating: 0, count: 7)
    @State private var showResults = false
    @State private var companionExpression: CompanionFaceView.Expression = .neutral
    private var questions: [String] {
        [
            String(localized: "test_question_1"),
            String(localized: "test_question_2"),
            String(localized: "test_question_3"),
            String(localized: "test_question_4"),
            String(localized: "test_question_5"),
            String(localized: "test_question_6"),
            String(localized: "test_question_7")
        ]
    }
    
    private var answerOptions: [String] {
        [
            String(localized: "test_option_not_at_all"),
            String(localized: "test_option_several_days"),
            String(localized: "test_option_more_than_half"),
            String(localized: "test_option_nearly_every_day")
        ]
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.themeBackground
                .ignoresSafeArea()
            
            if showResults {
                resultsView
            } else {
                testView
            }
        }
        .navigationBarHidden(true)
    }
    
    private var testView: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 20) {
                HStack {
                    Button(action: {
                        HapticFeedback.light()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.themeText)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(Color.themeCard)
                            )
                    }
                    
                    Spacer()
                    
                    Text(String.localizedStringWithFormat(String(localized: "test_progress"), currentQuestion + 1))
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.themeText.opacity(0.7))
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Progress bar
                ProgressView(value: Double(currentQuestion + 1), total: 7)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color.themeText))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal, 20)
            }
            .padding(.bottom, 40)
            
            Spacer()
            
            // Companion
            CompanionFaceView(expression: companionExpression)
                .padding(.bottom, 40)
            
            // Question
            VStack(spacing: 12) {
                Text(String(localized: "test_question_prefix"))
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.themeText.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 40)
                
                Text(questions[currentQuestion])
                    .font(.system(.title2, design: .serif))
                    .fontWeight(.medium)
                    .foregroundColor(.themeText)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            // Answer options
            VStack(spacing: 16) {
                ForEach(0..<answerOptions.count, id: \.self) { index in
                    Button(action: {
                        selectAnswer(index)
                    }) {
                        HStack(alignment: .top, spacing: 12) {
                            Text(answerOptions[index])
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(.themeText)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            if answers[currentQuestion] == index {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.themeText)
                            } else {
                                Circle()
                                    .stroke(Color.themeDivider, lineWidth: 2)
                                    .frame(width: 20, height: 20)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(answers[currentQuestion] == index ? Color.themeCard : Color.themeCard.opacity(0.5))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(answers[currentQuestion] == index ? Color.themeDivider : Color.themeDivider.opacity(0.5), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Continue button
            if answers[currentQuestion] >= 0 {
                Button(action: nextQuestion) {
                    Text(currentQuestion == 6 ? String(localized: "test_see_results") : String(localized: "test_continue"))
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.themeText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.themeCard)
                        )
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .onAppear {
            updateCompanionExpression()
        }
    }
    
    private var resultsView: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Companion with glow
            CompanionFaceView(expression: .happy, showGlow: true)
                .padding(.bottom, 20)
            
            // Results
            VStack(spacing: 20) {
                Text(String(localized: "test_results_title"))
                    .font(.system(.title, design: .serif))
                    .fontWeight(.semibold)
                    .foregroundColor(.themeText)
                
                let totalScore = answers.reduce(0, +)
                let category = getCategory(for: totalScore)
                
                VStack(spacing: 12) {
                    Text(String.localizedStringWithFormat(String(localized: "test_score"), totalScore))
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.themeText)
                    
                    Text(category.title)
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(category.color)
                    
                    Text(category.description)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.themeText.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.themeCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.themeDivider, lineWidth: 1)
                        )
                )
            }
            
            Spacer()
            
            // Done button
            Button(action: {
                saveResults()
                HapticFeedback.success()

                // Check if this is the first test completion and we haven't shown the permission prompt yet
                let reminderPromptShown = UserDefaults.standard.bool(forKey: "reminderPromptShown")
                let hasShownNotificationPrompt = UserDefaults.standard.bool(forKey: "hasShownNotificationPrompt")

                print("🧪 GAD7 Test Completion:")
                print("   - hasCompletedTest: \(hasCompletedTest)")
                print("   - gad7Entries.isEmpty: \(gad7Entries.isEmpty)")
                print("   - reminderPromptShown: \(reminderPromptShown)")
                print("   - hasShownNotificationPrompt: \(hasShownNotificationPrompt)")

                // Show notification permission if we haven't shown it yet
                if !hasShownNotificationPrompt && !reminderPromptShown {
                    print("   - ✅ Marking as first test completion")
                    // Mark this as the first test completion
                    UserDefaults.standard.set(true, forKey: "isFirstTestCompletion")
                    
                    // Show notification permission after a brief delay to allow navigation to complete
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        // Post a notification to trigger the permission check
                        NotificationCenter.default.post(name: NSNotification.Name("ShowNotificationPermission"), object: nil)
                    }
                } else {
                    print("   - ❌ Not marking as first test completion")
                }
                dismiss()
            }) {
                Text(String(localized: "test_done"))
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.themeText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.themeCard)
                    )
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
    
    private func selectAnswer(_ index: Int) {
        HapticFeedback.light()
        answers[currentQuestion] = index
        updateCompanionExpression()
    }
    
    private func nextQuestion() {
        HapticFeedback.rigid()
        
        if currentQuestion < 6 {
            withAnimation(.easeInOut(duration: 0.6)) {
                currentQuestion += 1
            }
            updateCompanionExpression()
        } else {
            withAnimation(.easeInOut(duration: 0.8)) {
                showResults = true
            }
        }
    }
    
    private func updateCompanionExpression() {
        let currentAnswer = answers[currentQuestion]
        withAnimation(.easeInOut(duration: 0.5)) {
            switch currentAnswer {
            case 0, 1:
                companionExpression = .happy
            case 2:
                companionExpression = .neutral
            case 3:
                companionExpression = .mouthLeft
            default:
                companionExpression = .neutral
            }
        }
    }
    
    private func saveResults() {
        let totalScore = answers.reduce(0, +)

        // Save to AppStorage for backward compatibility
        hasCompletedTest = true
        lastGAD7Score = totalScore
        lastGAD7DateTimestamp = Date().timeIntervalSince1970

        // Save to Core Data
        DataManager.shared.saveGAD7Entry(score: totalScore, answers: answers, date: Date())

        // Re-evaluate notifications (may schedule weekly reminder when due, respecting cooldown)
        ReminderScheduler.shared.evaluateAndScheduleIfNeeded()
    }
    
    private func getCategory(for score: Int) -> (title: String, description: String, color: Color) {
        switch score {
        case 0...4:
            return (String(localized: "test_category_minimal_title"), String(localized: "test_category_minimal_description"), Color.green)
        case 5...9:
            return (String(localized: "test_category_mild_title"), String(localized: "test_category_mild_description"), Color.yellow)
        case 10...14:
            return (String(localized: "test_category_moderate_title"), String(localized: "test_category_moderate_description"), Color.orange)
        default:
            return (String(localized: "test_category_severe_title"), String(localized: "test_category_severe_description"), Color.red)
        }
    }
}

#Preview {
    GAD7TestView()
}
