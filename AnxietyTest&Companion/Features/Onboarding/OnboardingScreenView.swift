//
//  OnboardingScreenView.swift
//  AnxietyTest&Companion
//
//  Created by Mehmet Ali Kısacık on 26.10.2025.
//

import SwiftUI

struct OnboardingScreenView: View {
    let title: String
    let message: String
    let companionExpression: CompanionFaceView.Expression
    let showGlow: Bool
    let buttonText: String
    let onContinue: () -> Void
    let customContent: AnyView?
    let imageName: String?
    
    @State private var showButton = false
    @State private var companionExpressionState: CompanionFaceView.Expression
    
    init(
        title: String,
        message: String,
        companionExpression: CompanionFaceView.Expression = .neutral,
        showGlow: Bool = false,
        buttonText: String = "Continue",
        onContinue: @escaping () -> Void,
        customContent: AnyView? = nil,
        imageName: String? = nil
    ) {
        self.title = title
        self.message = message
        self.companionExpression = companionExpression
        self.showGlow = showGlow
        self.buttonText = buttonText
        self.onContinue = onContinue
        self.customContent = customContent
        self.imageName = imageName
        self._companionExpressionState = State(initialValue: companionExpression)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Image (if provided)
            if let imageName = imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 280, maxHeight: 280)
                    .padding(.bottom, 30)
            }
            
            // Companion
            CompanionFaceView(
                expression: companionExpressionState,
                showGlow: showGlow
            )
            .padding(.bottom, 40)
            
            // Title
            Text(title)
                .font(.system(.title, design: .serif))
                .fontWeight(.semibold)
                .foregroundColor(.themeText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
            
            // Message or Custom Content
            if let customContent = customContent {
                customContent
                    .padding(.horizontal, 40)
            } else {
                TypingTextView(text: message) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showButton = true
                    }
                }
                .padding(.horizontal, 40)
            }
            
            Spacer()
            
            // Continue Button
            if showButton {
                Button(action: {
                    HapticFeedback.light()
                    onContinue()
                }) {
                    Text(buttonText)
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.themeText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.themeCard)
                        )
                        .scaleEffect(1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showButton)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .onAppear {
            // Trigger companion expression change after a delay for Screen 1
            if companionExpression == .happy && companionExpressionState == .neutral {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        companionExpressionState = .happy
                    }
                }
            }
        }
    }
}

// Custom button style for scale feedback
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    OnboardingScreenView(
        title: "Hey there.",
        message: "I'm here to help you understand how you've been feeling.",
        companionExpression: .neutral,
        onContinue: {
            print("Continue tapped")
        }
    )
    .background(Color.themeBackground)
}
