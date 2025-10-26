//
//  ExerciseInstructionPageView.swift
//  AnxietyTest&Companion
//
//  Individual instruction page with companion chat bubble and optional text field.
//

import SwiftUI

struct ExerciseInstructionPageView: View {
    let instruction: String
    let exerciseType: ExerciseType
    let exerciseTitle: String
    let promptType: InstructionPromptType
    let onContinue: (String?) -> Void
    
    @State private var userResponse = ""
    @State private var isTypingComplete = false
    
    private var companionExpression: CompanionFaceView.Expression {
        switch exerciseType {
        case .breathing:
            return .calm
        case .education:
            return .neutral
        case .prompt:
            return promptType == .question ? .happy : .neutral
        }
    }
    
    private var canContinue: Bool {
        if promptType == .question {
            return !userResponse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return isTypingComplete
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            
            // Companion with chat bubble
            CompanionChatBubbleView(
                message: instruction,
                showSpeakerIcon: false,
                companionExpression: companionExpression
            )
            .onAppear {
                // Reset user response for each new question
                if promptType == .question {
                    userResponse = ""
                }
                
                // For non-questions, mark as complete after animation
                if promptType != .question {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        isTypingComplete = true
                    }
                }
            }
            
            // Text field for questions - ALWAYS show for questions
            if promptType == .question {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your response:")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)
                    
                    TextEditor(text: $userResponse)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .frame(minHeight: 100)
                        .overlay(
                            // Placeholder text
                            Group {
                                if userResponse.isEmpty {
                                    VStack {
                                        HStack {
                                            Text("Type your response here...")
                                                .font(.body)
                                                .foregroundColor(.white.opacity(0.6))
                                                .padding(.leading, 20)
                                                .padding(.top, 24)
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        )
                        .onTapGesture {
                            // Allow text editor to receive focus
                        }
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    hideKeyboard()
                                }
                                .foregroundColor(.white)
                            }
                        }
                }
                .padding(.horizontal, 24)
            }
            
            Spacer()
            
            // Continue button
            if canContinue {
                Button(action: {
                    HapticFeedback.light()
                    onContinue(promptType == .question ? userResponse : nil)
                }) {
                    HStack {
                        Text(promptType == .question ? "Continue →" : "Next →")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "#6E63A4"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(radius: 3)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 24)
            }
        }
        .padding(.vertical, 20)
        .onTapGesture {
            // Dismiss keyboard when tapping outside text field
            hideKeyboard()
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Color(hex: "#6E63A4"), Color(hex: "#B5A7E0")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack {
            // Education instruction
            ExerciseInstructionPageView(
                instruction: "When you feel anxious, your body activates the fight-flight-freeze response.",
                exerciseType: .education,
                exerciseTitle: "What happens in anxiety",
                promptType: .statement,
                onContinue: { _ in }
            )
            
            Divider()
                .background(.white.opacity(0.3))
            
            // Question instruction
            ExerciseInstructionPageView(
                instruction: "Name 5 things you can see.",
                exerciseType: .prompt,
                exerciseTitle: "Grounding 5-4-3-2-1",
                promptType: .question,
                onContinue: { _ in }
            )
        }
    }
}
