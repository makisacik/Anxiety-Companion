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
    @State private var nameInput = ""
    
    private let totalPages = 6
    
    var body: some View {
        ZStack {
            // Background
            Color.themeBackground
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
                                .foregroundColor(.themeText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 15)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.themeCard)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(Color.themeDivider, lineWidth: 1)
                                        )
                                )
                                .onSubmit {
                                    if !nameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        saveNameAndContinue()
                                    }
                                }
                            
                            Button(action: saveNameAndContinue) {
                                Text("Continue")
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
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
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
                
                // Screen 6 - Ready
                OnboardingScreenView(
                    title: "You're doing great.",
                    message: "Let's begin with a short check-in.",
                    companionExpression: .happy,
                    showGlow: true,
                    buttonText: "Let's Begin",
                    onContinue: completeOnboarding
                )
                .tag(5)
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
