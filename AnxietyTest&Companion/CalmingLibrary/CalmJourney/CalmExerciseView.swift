//
//  CalmExerciseView.swift
//  AnxietyTest&Companion
//
//  Dynamic exercise renderer for different exercise types in Calm Journey.
//

import SwiftUI

struct CalmExerciseView: View {
    let exercise: CalmExercise
    let onComplete: () -> Void
    let onNext: () -> Void
    
    @State private var showScienceNote = false
    @State private var userResponse = ""
    @State private var isCompleted = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "#6E63A4"), Color(hex: "#B5A7E0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Exercise content based on type
                    exerciseContent
                    
                    // Science note
                    if showScienceNote {
                        scienceNoteSection
                    }
                    
                    // Action buttons
                    actionButtons
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Show science note after a brief delay for education and breathing exercises
            if exercise.type == .education || exercise.type == .breathing {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showScienceNote = true
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Exercise type and icon
            HStack {
                Image(systemName: exercise.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                
                Text(exercise.displayType)
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
            }
            
            // Title
            Text(exercise.title)
                .font(.system(.largeTitle, design: .serif))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
    }
    
    @ViewBuilder
    private var exerciseContent: some View {
        switch exercise.type {
        case .breathing:
            breathingExerciseContent
        case .prompt:
            promptExerciseContent
        case .education:
            educationExerciseContent
        }
    }
    
    private var breathingExerciseContent: some View {
        VStack(spacing: 20) {
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
            
            // Breathing animation placeholder
            VStack(spacing: 16) {
                Image(systemName: "lungs.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .padding(30)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.2))
                    )
                
                Text("Ready to start breathing?")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white)
            }
        }
    }
    
    private var promptExerciseContent: some View {
        VStack(spacing: 20) {
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
            
            // Text input
            VStack(alignment: .leading, spacing: 12) {
                Text("Your reflection:")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white)
                
                TextEditor(text: $userResponse)
                    .font(.system(.body, design: .rounded))
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
                    .frame(minHeight: 120)
            }
        }
    }
    
    private var educationExerciseContent: some View {
        VStack(spacing: 20) {
            // Instructions as informational cards
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, instruction in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "#B5A7E0"))
                            .frame(width: 24)
                        
                        Text(instruction)
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
            }
        }
    }
    
    private var scienceNoteSection: some View {
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
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            if exercise.type == .breathing {
                // For breathing exercises, show "Start Breathing" button
                Button(action: {
                    HapticFeedback.light()
                    // Navigate to existing breathing view
                    onComplete()
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
            } else {
                // For prompt and education exercises
                Button(action: {
                    HapticFeedback.success()
                    isCompleted = true
                    onComplete()
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Done")
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
                .disabled(exercise.type == .prompt && userResponse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(exercise.type == .prompt && userResponse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
            }
        }
    }
}

#Preview {
    CalmExerciseView(
        exercise: CalmExercise(
            id: 1,
            type: .prompt,
            title: "Grounding 5-4-3-2-1",
            instructions: [
                "Name 5 things you can see.",
                "Name 4 things you can touch.",
                "Name 3 things you can hear.",
                "Name 2 things you can smell.",
                "Name 1 thing you can taste."
            ],
            instructionPromptTypes: [
                .question,
                .question,
                .question,
                .question,
                .question
            ],
            scienceNote: "Grounding shifts attention from anxious thoughts to the present moment.",
            reportValue: .exclude
        ),
        onComplete: {},
        onNext: {}
    )
}
