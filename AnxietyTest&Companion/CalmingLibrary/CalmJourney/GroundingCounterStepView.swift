//
//  GroundingCounterStepView.swift
//  AnxietyTest&Companion
//
//  Individual step counter UI for the 5-4-3-2-1 grounding exercise.
//

import SwiftUI

struct GroundingCounterStepView: View {
    let emoji: String
    let title: String
    let instruction: String
    let totalCount: Int
    let onComplete: () -> Void
    
    @State private var currentCount: Int = 0
    @State private var showCompletion = false
    @State private var pulseScale: CGFloat = 1.0
    
    private var isComplete: Bool {
        currentCount >= totalCount
    }
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Emoji header
            Text(emoji)
                .font(.system(size: 60))
                .scaleEffect(pulseScale)
            
            // Title
            Text(title)
                .font(.system(.title, design: .serif))
                .fontWeight(.bold)
                .foregroundColor(.themeText)
                .multilineTextAlignment(.center)
            
            // Instruction
            Text(instruction)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.themeText.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Counter dots
            counterDotsView
            
            // Progress text
            if !showCompletion {
                Text(String.localizedStringWithFormat(String(localized: "grounding_counter_noticed"), currentCount, totalCount))
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.themeText.opacity(0.6))
            }
            
            Spacer()
            
            // Action button or completion message
            if showCompletion {
                completionView
            } else {
                tapButton
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 40)
    }
    
    private var counterDotsView: some View {
        HStack(spacing: 16) {
            ForEach(0..<totalCount, id: \.self) { index in
                Circle()
                    .fill(index < currentCount ? Color.themeText : Color.themeDivider)
                    .frame(width: 16, height: 16)
                    .scaleEffect(index == currentCount - 1 ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: currentCount)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var tapButton: some View {
        Button(action: handleTap) {
            Text(String(localized: "grounding_counter_tap_when"))
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
        .disabled(isComplete)
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }
    
    private var completionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.green)
                .scaleEffect(pulseScale)
            
            Text(String(localized: "grounding_step_complete"))
                .font(.system(.headline, design: .rounded))
                .foregroundColor(.themeText)
                .multilineTextAlignment(.center)
        }
        .transition(.opacity.combined(with: .scale))
        .padding(.bottom, 40)
        .onAppear {
            // Pulse animation
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                pulseScale = 1.1
            }
            
            // Auto-advance after 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeOut(duration: 0.3)) {
                    onComplete()
                }
            }
        }
    }
    
    private func handleTap() {
        guard currentCount < totalCount else { return }
        
        // Haptic feedback
        HapticFeedback.light()
        
        // Increment count
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            currentCount += 1
        }
        
        // Pulse animation
        withAnimation(.easeInOut(duration: 0.2)) {
            pulseScale = 1.15
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.2)) {
                pulseScale = 1.0
            }
        }
        
        // Check if complete
        if currentCount >= totalCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                HapticFeedback.success()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showCompletion = true
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    GroundingCounterStepView(
        emoji: "👁️",
        title: "Name 5 things you can see",
        instruction: "Say them out loud — tap when you name one.",
        totalCount: 5,
        onComplete: { print("Step completed!") }
    )
    .background(Color.themeBackground)
}
