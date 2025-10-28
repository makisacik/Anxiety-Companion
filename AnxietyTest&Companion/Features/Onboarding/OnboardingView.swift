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
    
    private let totalPages = 9
    
    var body: some View {
        ZStack {
            // Background
            Color.themeBackground
                .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                // Page 0 - Welcome / Disarm
                OnboardingScreenView(
                    title: "Hey there.",
                    message: "I'm your companion. You don't have to face anxious thoughts alone.\n\nLet's take a moment together to slow down.",
                    companionExpression: .neutral,
                    onContinue: nextPage,
                    imageName: "onboarding-image"
                )
                .tag(0)
                
                // Page 1 - Personalization
                OnboardingScreenView(
                    title: "What should I call you?",
                    message: "",
                    companionExpression: .mouthRight,
                    buttonText: "Continue",
                    onContinue: saveNameAndContinue,
                    customContent: AnyView(
                        VStack(spacing: 30) {
                            TypingTextView(text: "Names make things feel a little more human, don't they?\n\nI'd love to know yours.") {
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
                    ),
                    imageName: "confused-1"
                )
                .tag(1)
                
                // Page 2 - App Purpose (Honesty)
                OnboardingScreenView(
                    title: "A gentle space",
                    message: "This isn't therapy. Think of it as your daily pause —\na space to understand, track, and calm what you're feeling.",
                    companionExpression: .neutral,
                    onContinue: nextPage,
                    imageName: "meditate-1"
                )
                .tag(2)
                
                // Page 3 - Meet Your Companion
                OnboardingScreenView(
                    title: "This is me.",
                    message: "I'll check in with you, guide short exercises, and remind you to breathe when things feel heavy.\n\nReady to meet the calm version of your day?",
                    companionExpression: .mouthRight,
                    onContinue: nextPage,
                    imageName: "onboarding-image"
                )
                .tag(3)
                
                // Page 4 - Track Your Feelings (NEW)
                OnboardingScreenView(
                    title: "Understand your patterns",
                    message: "Each day, you can note how you feel — calm, tense, or anxious.\n\nYou'll also take a short GAD-7 test sometimes.\nIt helps you measure anxiety levels and see real progress.\n\nThe more you track, the more control you gain.",
                    companionExpression: .neutral,
                    onContinue: nextPage,
                    imageName: "tracking-header"
                )
                .tag(4)
                
                // Page 5 - Mind State Preview (Interactive)
                MindStatePreviewView(onContinue: nextPage)
                    .tag(5)
                
                // Page 6 - What You'll Do Together
                OnboardingScreenView(
                    title: "Tiny steps every day.",
                    message: "You'll answer a few gentle questions, track your feelings,\nand explore calming journeys designed to bring balance.\n\nOver time, you'll see how far you've come.",
                    companionExpression: .neutral,
                    onContinue: nextPage,
                    imageName: "walking-up"
                )
                .tag(6)
                
                // Page 7 - Free Trial / Transparency Screen
                OnboardingScreenView(
                    title: "Here's how your free trial works",
                    message: "You can start exploring all Calm Journeys and reflections for free for 7 days.\nAfter that, you can stay with the free plan or unlock everything for less than a coffee a month.\n\nNo pressure — this is your pace.",
                    companionExpression: .mouthRight,
                    onContinue: nextPage,
                    imageName: "onboarding-image"
                )
                .tag(7)
                
                // Page 8 - Ready to Begin
                OnboardingScreenView(
                    title: "You're doing great.",
                    message: "Let's start with a quick check-in — it only takes a minute.\n\nRemember, this is your safe space. I'm right here.",
                    companionExpression: .happy,
                    showGlow: true,
                    buttonText: "Let's Begin",
                    onContinue: completeOnboarding,
                    imageName: "onboarding-image"
                )
                .tag(8)
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
