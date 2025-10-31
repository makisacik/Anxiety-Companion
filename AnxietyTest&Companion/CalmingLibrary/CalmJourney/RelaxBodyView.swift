//
//  RelaxBodyView.swift
//  AnxietyTest&Companion
//
//  Interactive tap-based body relaxation exercise.
//

import SwiftUI

struct BodyPart: Identifiable {
    let id = UUID()
    let emoji: String
    let name: String
    var relaxed: Bool = false
}

struct RelaxBodyView: View {
    let onComplete: () -> Void
    let onStepProgress: (() -> Void)?
    
    init(onComplete: @escaping () -> Void, onStepProgress: (() -> Void)? = nil) {
        self.onComplete = onComplete
        self.onStepProgress = onStepProgress
    }
    
    @State private var bodyParts: [BodyPart] = [
        BodyPart(emoji: "🦶", name: String(localized: "body_part_toes")),
        BodyPart(emoji: "🦵", name: String(localized: "body_part_legs")),
        BodyPart(emoji: "🫄", name: String(localized: "body_part_stomach")),
        BodyPart(emoji: "🫁", name: String(localized: "body_part_chest")),
        BodyPart(emoji: "💪", name: String(localized: "body_part_shoulders")),
        BodyPart(emoji: "😌", name: String(localized: "body_part_face"))
    ]
    
    @State private var showCompletion = false
    @State private var pulseScale: CGFloat = 1.0
    
    private var allRelaxed: Bool {
        bodyParts.allSatisfy { $0.relaxed }
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.themeBackground
                .ignoresSafeArea()
            
            if showCompletion {
                completionScreen
                    .transition(.opacity.combined(with: .scale))
            } else {
                mainScreen
                    .transition(.opacity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: allRelaxed) { newValue in
            if newValue {
                showCompletionScreen()
            }
        }
    }
    
    private var mainScreen: some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 8) {
                Text("🌿")
                    .font(.system(size: 44))
                    .scaleEffect(pulseScale)
                Text(String(localized: "relax_title"))
                    .font(.system(.title3, design: .serif))
                    .fontWeight(.bold)
                    .foregroundColor(.themeText)
                    .multilineTextAlignment(.center)
                Text(String(localized: "relax_instruction"))
                    .font(.system(.footnote, design: .rounded))
                    .foregroundColor(.themeText.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            // Grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ], spacing: 10) {
                ForEach(Array(bodyParts.enumerated()), id: \.element.id) { index, bodyPart in
                    bodyPartCard(for: bodyPart, at: index)
                }
            }
            .padding(.horizontal, 24)
            Spacer(minLength: 8)
        }
        .padding(.vertical, 16)
    }

    private func bodyPartCard(for bodyPart: BodyPart, at index: Int) -> some View {
        Button(action: {
            relaxBodyPart(at: index)
        }) {
            VStack(spacing: 10) {
                // Emoji
                Text(bodyPart.emoji)
                    .font(.system(size: 34))
                    .frame(width: 54, height: 54)
                    .background(
                        Circle()
                            .fill(bodyPart.relaxed ? Color.themeCard : Color.themeCard.opacity(0.3))
                    )
                    .opacity(bodyPart.relaxed ? 0.6 : 1.0)

                // Label
                VStack(spacing: 4) {
                    Text(bodyPart.name)
                        .font(.system(.callout, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.themeText)

                    if bodyPart.relaxed {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.green)
                            Text(String(localized: "relax_relaxed"))
                                .font(.system(.caption2, design: .rounded))
                                .foregroundColor(.green)
                        }
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        Text(String(localized: "relax_tap"))
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(.themeText.opacity(0.5))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .padding(.vertical, 14)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(bodyPart.relaxed ? Color.themeCard.opacity(0.5) : Color.themeCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                bodyPart.relaxed ? Color.green.opacity(0.3) : Color.themeDivider,
                                lineWidth: bodyPart.relaxed ? 1.5 : 1
                            )
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(bodyPart.relaxed)
        .opacity(bodyPart.relaxed ? 0.75 : 1.0)
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
                .scaleEffect(pulseScale)
            
            // Title
            Text(String(localized: "relax_complete"))
                .font(.system(.largeTitle, design: .serif))
                .fontWeight(.bold)
                .foregroundColor(.themeText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            // Message
            Text(String(localized: "completion_breath"))
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
                Text(String(localized: "relax_done"))
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
        .onAppear {
            // Pulse animation for completion icon
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                pulseScale = 1.1
            }
        }
    }
    
    private func relaxBodyPart(at index: Int) {
        guard index < bodyParts.count, !bodyParts[index].relaxed else { return }
        
        // Haptic feedback
        HapticFeedback.light()
        
        // Mark as relaxed with animation
        withAnimation(.easeInOut(duration: 0.4)) {
            bodyParts[index].relaxed = true
        }
        
        // Notify progress
        onStepProgress?()
        
        // Additional haptic for final part
        if allRelaxed {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                HapticFeedback.success()
            }
        }
    }
    
    private func showCompletionScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showCompletion = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RelaxBodyView(onComplete: {
            print("Relax body exercise completed!")
        })
    }
}
