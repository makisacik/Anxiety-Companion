//
//  CalmJourneyBreathingView.swift
//  AnxietyTest&Companion
//
//  Specialized breathing view for Calm Journey exercises.
//

import SwiftUI

struct CalmJourneyBreathingView: View {
    let exercise: CalmExercise
    let onComplete: () -> Void
    @StateObject private var manager = BreathingManager()
    @Environment(\.dismiss) private var dismiss
    @State private var showBreathingAnimation = false
    
    var body: some View {
        ZStack {
            if !showBreathingAnimation {
                introView
            } else {
                breathingView
            }
        }
        .navigationTitle("Breathing Exercise")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbarBackground(Color(hex: "#6E63A4"), for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
    
    private var introView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Icon
                Image(systemName: "lungs.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                    .padding(20)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.2))
                    )
                    .padding(.top, 20)

                // Title
                Text(exercise.title)
                    .font(.system(.title, design: .serif))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                // Instructions
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, instruction in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(index + 1)")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                )

                            Text(instruction)
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                                .fixedSize(horizontal: false, vertical: true)

                            Spacer()
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)

                // Science note
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "#B5A7E0"))
                        
                        Text("The Science")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    
                    Text(exercise.scienceNote)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: "#B5A7E0").opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)

                // Start Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showBreathingAnimation = true
                    }
                    HapticFeedback.light()
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Start Breathing Exercise")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(Color(hex: "#6E63A4"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 100) // Extra padding to ensure button is above tab bar
            }
        }
    }
    
    private var breathingView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Breathing animation
            BreathingCircleViewCustom(
                isExpanded: $manager.isExpanded,
                onPhaseChange: manager.updatePhase
            )
            
            Spacer()
            
            // Completion message and button
            if manager.isFinished {
                VStack(spacing: 20) {
                    Text("Great job! 🌿")
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("You've completed the breathing exercise")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    Button("Continue to Next Exercise →") {
                        print("🫁 User tapped continue button")
                        HapticFeedback.success()
                        onComplete()
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    )
                    .foregroundColor(Color(hex: "#6E63A4"))
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                }
                .transition(.opacity.combined(with: .offset(y: 20)))
                .animation(.easeInOut(duration: 0.6), value: manager.isFinished)
                .padding(.bottom, 50)
            } else {
                // Show a manual finish button as fallback
                Button("Finish Exercise") {
                    print("🫁 User manually finished exercise")
                    manager.finishSession()
                    HapticFeedback.success()
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white.opacity(0.8))
                )
                .foregroundColor(Color(hex: "#6E63A4"))
                .font(.system(.body, design: .rounded))
                .fontWeight(.semibold)
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    CalmJourneyBreathingView(
        exercise: CalmExercise(
            id: 1,
            type: .breathing,
            title: "Box Breathing",
            instructions: [
                "Inhale for 4 seconds.",
                "Hold your breath for 4 seconds.",
                "Exhale for 4 seconds.",
                "Hold again for 4 seconds.",
                "Repeat for 1–2 minutes."
            ],
            instructionPromptTypes: [
                .action,
                .action,
                .action,
                .action,
                .action
            ],
            scienceNote: "Box breathing lowers heart rate and activates the parasympathetic nervous system.",
            reportValue: .exclude
        ),
        onComplete: {}
    )
}
