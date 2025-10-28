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
    let showCompanion: Bool
    let nextStepIsQuestion: Bool

    init(instruction: String, exerciseType: ExerciseType, exerciseTitle: String, promptType: InstructionPromptType, onContinue: @escaping (String?) -> Void, showCompanion: Bool, nextStepIsQuestion: Bool = false) {
        self.instruction = instruction
        self.exerciseType = exerciseType
        self.exerciseTitle = exerciseTitle
        self.promptType = promptType
        self.onContinue = onContinue
        self.showCompanion = showCompanion
        self.nextStepIsQuestion = nextStepIsQuestion
    }
    
    @State private var userResponse = ""
    @State private var isTypingComplete = false
    @FocusState private var isTextFieldFocused: Bool
    
    private var companionExpression: CompanionFaceView.Expression {
        switch exerciseType {
        case .breathing:
            return .calm
        case .education:
            return .neutral
        case .prompt:
            return promptType == .question ? .happy : .neutral
        case .grounding:
            return .calm
        case .relaxBody:
            return .calm
        }
    }
    
    private var canContinue: Bool {
        if promptType == .question {
            return !userResponse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return isTypingComplete
    }
    
    var body: some View {
        // A duolingo-style page: companion/bubble at top, card content in the middle,
        // and a pinned continue button at the bottom (inside the safe area).
        VStack(spacing: 0) {
            // Note: Companion rendering is removed from this view to avoid duplication.
            // The parent (session container) is responsible for showing the companion
            // and bubble row. This view only renders the instruction/card and input.

            // Lifecycle: reset or auto-complete depending on prompt type
            Spacer().frame(height: 0) // no-op spacer to attach onAppear below

            // Main content card — for questions show a TextEditor inside a glass card.
            if promptType == .question {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)

                    TextEditor(text: $userResponse)
                        .font(.body)
                        .foregroundColor(.themeText)
                        .background(Color.clear)
                        .scrollContentBackground(.hidden)
                        .padding(16)
                        .focused($isTextFieldFocused)

                    if userResponse.isEmpty {
                        Text("Type your response here...")
                            .font(.body)
                            .foregroundColor(.themeText.opacity(0.6))
                            .padding(EdgeInsets(top: 24, leading: 28, bottom: 0, trailing: 0))
                    }
                }
                .frame(minHeight: 160)
                .padding(.horizontal, 24)
                .padding(.top, 8)
            } else {
                // For non-question pages, only show the instruction card if companion is not shown
                // (when companion is shown above, the instruction is already displayed in the chat bubble)
                if showCompanion {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.themeCard)
                        .overlay(
                            Text(instruction)
                                .font(.body)
                                .foregroundColor(.themeText)
                                .padding(20)
                                .multilineTextAlignment(.leading)
                        )
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                }
                // When showCompanion is false, the instruction is already shown in the companion chat bubble above
                // so we don't need to display it again here
            }

            Spacer()
        }
        .padding(.vertical, 20)
        .onTapGesture { hideKeyboard() }
        .onAppear {
            // Ensure lifecycle logic runs when this view appears.
            if promptType == .question {
                userResponse = ""
                // Auto-focus if this is a question step and next step is also a question
                if nextStepIsQuestion {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isTextFieldFocused = true
                    }
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    isTypingComplete = true
                }
            }
        }
        // Pin the continue button into the safe area so it's always visible like Duolingo
        .safeAreaInset(edge: .bottom) {
            // Always render the button but disable it until allowed.
            Button(action: {
                HapticFeedback.light()
                onContinue(promptType == .question ? userResponse : nil)
                
                // Don't dismiss keyboard if next step is a question - let auto-focus handle it
                if !nextStepIsQuestion {
                    hideKeyboard()
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.themeText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.themeCard)
                            .shadow(radius: 3)
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(!canContinue)
            .opacity(canContinue ? 1.0 : 0.6)
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ZStack {
        Color.themeBackground
            .ignoresSafeArea()
        
        VStack {
            // Education instruction
            ExerciseInstructionPageView(
                instruction: "When you feel anxious, your body activates the fight-flight-freeze response.",
                exerciseType: .education,
                exerciseTitle: "What happens in anxiety",
                promptType: .statement,
                onContinue: { _ in },
                showCompanion: true
            )
            
            Divider()
                .background(.white.opacity(0.3))
            
            // Question instruction
            ExerciseInstructionPageView(
                instruction: "Name 5 things you can see.",
                exerciseType: .prompt,
                exerciseTitle: "Grounding 5-4-3-2-1",
                promptType: .question,
                onContinue: { _ in },
                showCompanion: true
            )
        }
    }
}
