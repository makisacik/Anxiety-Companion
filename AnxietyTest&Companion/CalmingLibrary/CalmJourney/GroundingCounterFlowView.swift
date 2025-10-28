//
//  GroundingCounterFlowView.swift
//  AnxietyTest&Companion
//
//  Orchestrates the 5-4-3-2-1 grounding sequence with auto-advancing steps.
//

import SwiftUI

struct GroundingCounterStep {
    let emoji: String
    let title: String
    let instruction: String
    let totalCount: Int
}

struct GroundingCounterFlowView: View {
    let onComplete: () -> Void
    let onStepProgress: (() -> Void)?
    
    init(onComplete: @escaping () -> Void, onStepProgress: (() -> Void)? = nil) {
        self.onComplete = onComplete
        self.onStepProgress = onStepProgress
    }
    
    @Environment(\.dismiss) private var dismiss
    @State private var currentStepIndex: Int = 0
    @State private var showCompletion = false
    
    private let steps: [GroundingCounterStep] = [
        GroundingCounterStep(
            emoji: "👁️",
            title: "Name 5 things you can see",
            instruction: "Say them out loud — tap when you name one.",
            totalCount: 5
        ),
        GroundingCounterStep(
            emoji: "✋",
            title: "Name 4 things you can touch",
            instruction: "Feel them physically — tap when you name one.",
            totalCount: 4
        ),
        GroundingCounterStep(
            emoji: "👂",
            title: "Name 3 things you can hear",
            instruction: "Listen closely — tap when you hear one.",
            totalCount: 3
        ),
        GroundingCounterStep(
            emoji: "👃",
            title: "Name 2 things you can smell",
            instruction: "Take a deep breath — tap when you notice one.",
            totalCount: 2
        ),
        GroundingCounterStep(
            emoji: "👅",
            title: "Name 1 thing you can taste",
            instruction: "Notice it in your mouth — tap when you sense it.",
            totalCount: 1
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color.themeBackground
                .ignoresSafeArea()
            
            if showCompletion {
                completionScreen
                    .transition(.opacity.combined(with: .scale))
            } else if currentStepIndex < steps.count {
                let step = steps[currentStepIndex]
                GroundingCounterStepView(
                    emoji: step.emoji,
                    title: step.title,
                    instruction: step.instruction,
                    totalCount: step.totalCount,
                    onComplete: advanceToNextStep
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .trailing)),
                    removal: .opacity.combined(with: .move(edge: .leading))
                ))
                .id("step-\(currentStepIndex)")
            }
        }
        .navigationTitle("Grounding 5-4-3-2-1")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var completionScreen: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            Image(systemName: "leaf.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
                .padding(30)
                .background(
                    Circle()
                        .fill(Color.themeCard)
                )
            
            // Title
            Text("🌿 Grounding complete")
                .font(.system(.largeTitle, design: .serif))
                .fontWeight(.bold)
                .foregroundColor(.themeText)
                .multilineTextAlignment(.center)
            
            // Message
            Text("You've re-centered in the present moment.")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.themeText.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            // Done button
            Button(action: {
                HapticFeedback.success()
                onComplete()
            }) {
                Text("Done")
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.themeBackgroundPure)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.themeText)
                    )
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
    }
    
    private func advanceToNextStep() {
        let nextIndex = currentStepIndex + 1
        
        // Notify progress
        onStepProgress?()
        
        if nextIndex < steps.count {
            // Move to next step
            withAnimation(.easeInOut(duration: 0.4)) {
                currentStepIndex = nextIndex
            }
        } else {
            // All steps complete, show completion screen
            withAnimation(.easeInOut(duration: 0.4)) {
                showCompletion = true
            }
            HapticFeedback.success()
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        GroundingCounterFlowView(onComplete: {
            print("Grounding flow completed!")
        })
    }
}
