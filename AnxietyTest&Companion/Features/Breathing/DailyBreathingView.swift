//
//  DailyBreathingView.swift
//  AnxietyTest&Companion
//
//  Main breathing exercise view with exercise selection and completion.
//

import SwiftUI

struct DailyBreathingView: View {
    var onComplete: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedExercise: BreathingExerciseType? = nil
    @State private var showExerciseSelection = false
    @State private var isBreathing = false
    @State private var isExpanded = false
    @State private var isFinished = false
    @State private var showCompletion = false
    @State private var breathingViewId = UUID()
    
    var body: some View {
        ZStack {
            // Background
            Color.themeBackground
                .ignoresSafeArea()
            
            if !isBreathing {
                welcomeView
            } else if let exercise = selectedExercise {
                breathingSessionView(exercise: exercise)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    if isBreathing {
                        // Go back to welcome view and reset breathing state
                        withAnimation {
                            isBreathing = false
                            isFinished = false
                            isExpanded = false
                            selectedExercise = nil
                            breathingViewId = UUID() // Force recreation of breathing view
                        }
                    } else {
                        // Dismiss entire view
                        dismiss()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.themeText)
                        .font(.system(size: 18, weight: .medium))
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showExerciseSelection) {
            BreathingExerciseSelectionView { exercise in
                selectedExercise = exercise
                startBreathing()
            }
        }
    }
    
    // MARK: - Welcome View
    private var welcomeView: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Icon
                Image(systemName: "wind")
                    .font(.system(size: 70))
                    .foregroundColor(.themeText)
                    .padding(30)
                    .background(
                        Circle()
                            .fill(Color.themeCard)
                            .shadow(color: Color.themeText.opacity(0.1), radius: 10)
                    )
                    .padding(.top, 20)
                
                // Title
                VStack(spacing: 8) {
                    Text("Start Your Calm Minute")
                        .font(.system(.largeTitle, design: .serif))
                        .fontWeight(.bold)
                        .foregroundColor(.themeText)
                        .multilineTextAlignment(.center)
                    
                    Text("Take a moment to breathe and center yourself")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.themeText.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                
                // Benefits
                VStack(spacing: 16) {
                    benefitRow(
                        icon: "heart.circle.fill",
                        title: "Calm Your Mind",
                        description: "Slow breathing activates your body's natural relaxation response"
                    )
                    
                    benefitRow(
                        icon: "brain.head.profile",
                        title: "Focus & Clarity",
                        description: "Bring your attention to the present moment with intention"
                    )
                    
                    benefitRow(
                        icon: "moon.stars.fill",
                        title: "Reduce Tension",
                        description: "Release physical and mental stress with each exhale"
                    )
                }
                .padding(.horizontal, 30)
                
                Spacer()
                    .frame(height: 20)
                
                // Start Button
                Button(action: {
                    HapticFeedback.soft()
                    showExerciseSelection = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 22))
                        Text("Choose Exercise & Begin")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.themeBackgroundPure)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.themeText)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 30)
                
                Spacer()
                    .frame(height: 40)
            }
        }
    }
    
    private func benefitRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(.themeText)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.themeText)

                Text(description)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.themeText.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.themeCard)
        )
    }
    
    // MARK: - Breathing Session View
    private func breathingSessionView(exercise: BreathingExerciseType) -> some View {
        VStack(spacing: 30) {
            Spacer()
                .frame(height: 20)
            
            // Exercise name
            VStack(spacing: 8) {
                Text(exercise.rawValue)
                    .font(.system(.title, design: .serif))
                    .fontWeight(.semibold)
                    .foregroundColor(.themeText)
                
                Text("Follow the circle's rhythm")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.themeText.opacity(0.6))
            }
            
            // Breathing circle
            ConfigurableBreathingCircleView(
                isExpanded: $isExpanded,
                exerciseType: exercise,
                totalCycles: 5,
                onPhaseChange: { phase in
                    handlePhaseChange(phase)
                },
                onComplete: {
                    completeSession()
                }
            )
            .frame(height: 300)
            .id(breathingViewId)
            
            Spacer()
            
            // Finish button (only shown when complete)
            if isFinished {
                completionView
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding(.horizontal, 30)
    }
    
    private var completionView: some View {
        VStack(spacing: 20) {
            // Success message
            VStack(spacing: 8) {
                Text("Well done — you took a minute for calm 🌿")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.themeText)
                    .multilineTextAlignment(.center)
                
                Text("Your mind and body thank you")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.themeText.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            // Finish button
            Button(action: {
                HapticFeedback.soft()
                dismiss()
            }) {
                Text("Finish")
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.themeBackgroundPure)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.themeText)
                    )
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 30)
    }
    
    // MARK: - Helpers
    private func startBreathing() {
        breathingViewId = UUID() // Generate new ID to force recreation
        withAnimation(.easeInOut(duration: 0.5)) {
            isBreathing = true
        }
    }
    
    private func handlePhaseChange(_ phase: String) {
        switch phase {
        case "inhale":
            HapticFeedback.soft()
        case "hold":
            HapticFeedback.light()
        case "exhale":
            HapticFeedback.soft()
        case "end":
            // Session complete
            break
        default:
            break
        }
    }
    
    private func completeSession() {
        HapticFeedback.success()
        withAnimation(.spring()) {
            isFinished = true
        }
        onComplete?()
    }
}
