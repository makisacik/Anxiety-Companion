//
//  OnboardingView.swift
//  AnxietyTest&Companion
//
//  Created by Mehmet Ali Kısacık on 26.10.2025.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("userName") private var userName = ""
    @State private var currentPage = 0
    @State private var selectedMood: MoodPickerView.Mood? = nil
    @State private var companionExpression: CompanionFaceView.Expression = .neutral
    @State private var nameInput = ""
    
    private let totalPages = 7
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "#6E63A4"), Color(hex: "#B5A7E0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                // Screen 1 - Welcome
                OnboardingScreenView(
                    title: "Hey there.",
                    message: "I'm here to help you understand how you've been feeling.",
                    companionExpression: .neutral,
                    onContinue: nextPage
                )
                .tag(0)
                
                // Screen 2 - Name Input
                OnboardingScreenView(
                    title: "What should I call you?",
                    message: "",
                    companionExpression: .mouthRight,
                    buttonText: "Continue",
                    onContinue: saveNameAndContinue,
                    customContent: AnyView(
                        VStack(spacing: 30) {
                            TypingTextView(text: "I'd love to know your name so I can greet you properly.") {
                                // Text typing complete
                            }
                            
                            TextField("Your name", text: $nameInput)
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 15)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.white.opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                .onSubmit {
                                    if !nameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        saveNameAndContinue()
                                    }
                                }
                            
                            if !nameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Button(action: saveNameAndContinue) {
                                    Text("Continue")
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
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                            }
                        }
                        .onTapGesture {
                            // Dismiss keyboard when tapping outside the TextField
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    )
                )
                .tag(1)
                
                // Screen 3 - Purpose
                OnboardingScreenView(
                    title: "A Safe Space",
                    message: "This isn't a therapy app. It's a gentle space for self-check and reflection.",
                    companionExpression: .neutral,
                    onContinue: nextPage
                )
                .tag(2)
                
                // Screen 4 - Meet Companion
                OnboardingScreenView(
                    title: "Your Companion",
                    message: "This is your companion. You'll take small steps together.",
                    companionExpression: .mouthRight,
                    onContinue: nextPage
                )
                .tag(3)
                
                // Screen 5 - Empowerment
                OnboardingScreenView(
                    title: "Understanding",
                    message: "Understanding your anxiety is the first step toward feeling better.",
                    companionExpression: .neutral,
                    onContinue: nextPage
                )
                .tag(4)
                
                // Screen 6 - Personal Touch (Mood Picker)
                OnboardingScreenView(
                    title: "How are you feeling today?",
                    message: "",
                    companionExpression: companionExpression,
                    buttonText: "Continue",
                    onContinue: nextPage,
                    customContent: AnyView(
                        VStack(spacing: 30) {
                            MoodPickerView(selectedMood: $selectedMood) { expression in
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    companionExpression = expression
                                }
                            }
                            
                            if selectedMood != nil {
                                Button(action: nextPage) {
                                    Text("Continue")
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
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                            }
                        }
                    )
                )
                .tag(5)
                
                // Screen 7 - Ready
                OnboardingScreenView(
                    title: "You're doing great.",
                    message: "Let's begin with a short check-in.",
                    companionExpression: .happy,
                    showGlow: true,
                    buttonText: "Let's Begin",
                    onContinue: completeOnboarding
                )
                .tag(6)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeOut(duration: 0.8), value: currentPage)
        }
    }
    
    private func nextPage() {
        HapticFeedback.rigid()
        withAnimation(.easeOut(duration: 0.8)) {
            if currentPage < totalPages - 1 {
                currentPage += 1
            }
        }
    }
    
    private func saveNameAndContinue() {
        // Dismiss keyboard first
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        let trimmedName = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty {
            userName = trimmedName
        } else {
            userName = "Friend" // Fallback name
        }
        HapticFeedback.light()
        nextPage()
    }
    
    private func completeOnboarding() {
        HapticFeedback.success()
        withAnimation(.easeOut(duration: 0.8)) {
            hasCompletedOnboarding = true
        }
    }
}

#Preview {
    OnboardingView()
}
