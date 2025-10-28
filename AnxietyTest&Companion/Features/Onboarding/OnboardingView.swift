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
    
    private let totalPages = 7
    
    var body: some View {
        ZStack {
            // Background
            Color.themeBackground
                .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                // Page 0 - Welcome / Disarm
                OnboardingScreenView(
                    title: "Hey there.",
                    message: "I'm your companion. You don’t have to face anxious thoughts alone.\n\nLet’s take a slow breath together, just you and me.",
                    companionExpression: .neutral,
                    onContinue: nextPage,
                    imageName: "onboarding-image"
                )
                .tag(0)

                // Page 1 - Personalization
                OnboardingScreenView(
                    title: "What should I call you?",
                    message: "",
                    companionExpression: .happy,
                    buttonText: "Continue",
                    onContinue: saveNameAndContinue,
                    customContent: AnyView(
                        VStack(spacing: 30) {
                            TypingTextView(text: "Names make things feel warmer, don't they?\n\nI'd love to know yours.") {
                                // Typing complete
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
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    ),
                    imageName: "hands-open-smile",
                    useScrollView: true
                )
                .tag(1)

                // Page 2 - App Purpose (Honesty)
                OnboardingScreenView(
                    title: "A gentle space",
                    message: "This is your space.\nA space to breathe, track, and gently understand your mind.",
                    companionExpression: .neutral,
                    onContinue: nextPage,
                    imageName: "meditate-1"
                )
                .tag(2)

                // Page 3 - Track Your Feelings
                OnboardingScreenView(
                    title: "Notice your patterns",
                    message: "Each day, you can note how you feel — calm, tense, or anxious.\n\nWith short GAD-7 checks, you'll start to see your own progress unfold.",
                    companionExpression: .neutral,
                    onContinue: nextPage,
                    imageName: "brain-handshake"
                )
                .tag(3)

                // Page 4 - Mind State Preview (Interactive)
                MindStatePreviewView(onContinue: nextPage)
                    .tag(4)

                // Page 5 - Free Trial / Transparency Screen
                FreeTrialView(onContinue: nextPage)
                    .tag(5)

                // Page 6 - Ready to Begin
                OnboardingScreenView(
                    title: "You're doing great.",
                    message: "Let's dive in.\n\nI'll be right here with you.",
                    companionExpression: .happy,
                    showGlow: true,
                    buttonText: "Let's Begin",
                    onContinue: completeOnboarding,
                    imageName: "shadow-hero"
                )
                .tag(6)

            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeOut(duration: 0.8), value: currentPage)
            .highPriorityGesture(
                DragGesture()
                    .onChanged { _ in }
            )
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
