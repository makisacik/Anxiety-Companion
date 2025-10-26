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
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "#6E63A4"), Color(hex: "#B5A7E0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if !showBreathingAnimation {
                introView
            } else {
                breathingView
            }
        }
        .navigationBarHidden(true)
    }
    
    private var introView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon
            Image(systemName: "lungs.fill")
                .font(.system(size: 60))
                .foregroundColor(.white)
                .padding(30)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.2))
                )
            
            // Title
            Text(exercise.title)
                .font(.system(.largeTitle, design: .serif))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Instructions
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, instruction in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
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
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 30)
            
            // Science note
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 20))
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
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "#B5A7E0").opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 30)
            
            Spacer()
            
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
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
    }
    
    private var breathingView: some View {
        VStack(spacing: 30) {
            // Back button
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showBreathingAnimation = false
                    }
                    HapticFeedback.light()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            Spacer()
            
            // Breathing animation
            BreathingCircleViewCustom(
                isExpanded: $manager.isExpanded,
                onPhaseChange: manager.updatePhase
            )
            
            Spacer()
            
            // Finish button
            Button("Complete Exercise 🌿") {
                manager.finishSession()
                HapticFeedback.success()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    onComplete()
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white)
            )
            .foregroundColor(Color(hex: "#6E63A4"))
            .font(.system(.body, design: .rounded))
            .fontWeight(.semibold)
            .opacity(manager.isFinished ? 1 : 0)
            .animation(.easeInOut, value: manager.isFinished)
            .padding(.bottom, 50)
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
            scienceNote: "Box breathing lowers heart rate and activates the parasympathetic nervous system."
        ),
        onComplete: {}
    )
}
