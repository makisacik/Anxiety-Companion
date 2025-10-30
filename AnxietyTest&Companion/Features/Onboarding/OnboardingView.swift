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
                    message: "I'm your companion, here to help you face anxious thoughts with calm and care.",
                    companionExpression: .neutral,
                    onContinue: nextPage,
                    imageName: "question-hand"
                )
                .tag(0)
                .id(0)

                // Page 1 - Personalization
                OnboardingScreenView(
                    title: "What should I call you?",
                    message: "",
                    companionExpression: .happy,
                    buttonText: "Continue",
                    onContinue: saveNameAndContinue,
                    customContent: AnyView(
                        VStack(spacing: 30) {
                            TypingTextView(text: "Names make things feel warmer, don't they? I'd love to know yours.") {
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
                    imageName: "",
                    useScrollView: true
                )
                .tag(1)
                .id(1)

                // Page 2 - App Purpose (Honesty)
                OnboardingScreenView(
                    title: "A gentle space",
                    message: "This is your space to track and gently understand your mind.",
                    companionExpression: .neutral,
                    onContinue: nextPage,
                    imageName: "meditate-1"
                )
                .tag(2)
                .id(2)

                // Page 3 - Track Your Feelings
                OnboardingScreenView(
                    title: "Notice your patterns",
                    message: "Track your worries and use brief GAD-7 checks to notice your improvement..",
                    companionExpression: .neutral,
                    onContinue: nextPage,
                    imageName: "brain-handshake"
                )
                .tag(3)
                .id(3)

                // Page 4 - Mind State Preview (Interactive)
                MindStatePreviewView(onContinue: nextPage)
                    .tag(4)
                    .id(4)

                // Page 5 - Free Trial / Transparency Screen
                FreeTrialView(onContinue: nextPage)
                    .tag(5)
                    .id(5)

                // Page 6 - Ready to Begin
                OnboardingScreenView(
                    title: "You're doing great.",
                    message: "Let's dive in. I'll be right here with you.",
                    companionExpression: .happy,
                    showGlow: true,
                    buttonText: "Let's Begin",
                    onContinue: completeOnboarding,
                    imageName: "shadow-hero"
                )
                .tag(6)
                .id(6)

            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.4), value: currentPage)
        }
    }
    
    private func nextPage() {
        HapticFeedback.rigid()
        withAnimation(.easeInOut(duration: 0.4)) {
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
        
        // Add a small delay to allow keyboard to dismiss smoothly
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.4)) {
                if currentPage < totalPages - 1 {
                    currentPage += 1
                }
            }
        }
    }
    
    private func completeOnboarding() {
        HapticFeedback.success()
        withAnimation(.easeInOut(duration: 0.4)) {
            hasCompletedOnboarding = true
        }
    }
}


#Preview {
    OnboardingView()
}
