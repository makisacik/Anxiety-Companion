//
//  CalmLevelSessionView.swift
//  AnxietyTest&Companion
//
//  Main session container managing page-by-page instruction flow with companion chat bubbles.
//

import SwiftUI

enum SessionPhase {
    case intro
    case session
    case completion
}

struct CalmLevelSessionView: View {
    let level: CalmLevel
    let onLevelCompleted: (Int) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentPhase: SessionPhase = .intro
    @State private var currentStepIndex = 0
    @State private var instructionSteps: [InstructionStep] = []
    @State private var userResponses: [Int: String] = [:] // stepId: response
    @State private var showBreathingView = false
    
    private var currentStep: InstructionStep? {
        guard currentStepIndex < instructionSteps.count else { return nil }
        return instructionSteps[currentStepIndex]
    }
    
    private var isLastStep: Bool {
        return currentStepIndex >= instructionSteps.count - 1
    }
    
    private var totalSteps: Int {
        return instructionSteps.count
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "#6E63A4"), Color(hex: "#B5A7E0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            sessionContent
        }
        .navigationBarHidden(true)
        .onAppear {
            generateInstructionSteps()
        }
    }
    
    @ViewBuilder
    private var sessionContent: some View {
        switch currentPhase {
        case .intro:
            introView
                .transition(.opacity.combined(with: .offset(y: -20)))
            
        case .session:
            sessionView
                .transition(.opacity.combined(with: .offset(y: 20)))
            
        case .completion:
            CalmLevelCompletionCard(
                level: level,
                onRepeatSession: {
                    repeatSession()
                },
                onBackToJourney: {
                    backToJourney()
                }
            )
            .transition(.opacity.combined(with: .offset(y: 20)))
        }
    }
    
    private var introView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Level icon/emoji
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Text(levelIcon)
                        .font(.system(size: 40))
                }
                
                Text("Today's calm practice: \(level.title) 🌤️")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            
            // Summary
            Text(level.summary)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            Spacer()
            
            // Start Session Button
            Button(action: {
                HapticFeedback.light()
                startSession()
            }) {
                HStack {
                    Image(systemName: "play.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Start Session")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
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
            .padding(.bottom, 50)
        }
    }
    
    private var sessionView: some View {
        VStack(spacing: 0) {
            // Header with progress
            headerSection
            
            if showBreathingView, let step = currentStep, step.exerciseType == .breathing {
                // Find the original exercise to get all instructions
                let originalExercise = level.exercises.first { $0.id == step.exerciseId }
                CalmJourneyBreathingView(
                    exercise: originalExercise ?? CalmExercise(
                        id: step.exerciseId,
                        type: step.exerciseType,
                        title: step.exerciseTitle,
                        instructions: [step.instruction],
                        instructionPromptTypes: [step.promptType],
                        scienceNote: ""
                    ),
                    onComplete: {
                        handleBreathingCompletion()
                    }
                )
            } else {
                // Current instruction step
                if let currentStep = currentStep {
                    ExerciseInstructionPageView(
                        instruction: currentStep.instruction,
                        exerciseType: currentStep.exerciseType,
                        exerciseTitle: currentStep.exerciseTitle,
                        promptType: currentStep.promptType,
                        onContinue: { response in
                            handleStepCompletion(response)
                        }
                    )
                    .id("step-\(currentStep.id)") // Force new view instance for each step
                    .onAppear {
                        print("🔍 Rendering ExerciseInstructionPageView with:")
                        print("🔍   instruction: '\(currentStep.instruction)'")
                        print("🔍   exerciseType: \(currentStep.exerciseType)")
                        print("🔍   promptType: \(currentStep.promptType)")
                        print("🔍   stepId: \(currentStep.id)")
                    }
                }
            }
        }
    }
    
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: {
                    HapticFeedback.light()
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("Level \(level.id)")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // Progress indicator
            HStack {
                Text("Progress")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(currentStepIndex + 1)/\(totalSteps)")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            ProgressView(value: Double(currentStepIndex + 1), total: Double(totalSteps))
                .progressViewStyle(LinearProgressViewStyle(tint: Color.white))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
    
    private func generateInstructionSteps() {
        var steps: [InstructionStep] = []
        var stepId = 1
        
        for exercise in level.exercises {
            print("🔍 Processing exercise: \(exercise.title) (type: \(exercise.type))")
            print("🔍 Instructions: \(exercise.instructions)")
            print("🔍 Prompt types: \(exercise.instructionPromptTypes)")
            
            if exercise.type == .breathing {
                // For breathing exercises, show a proper explanation instead of the first instruction
                let explanation = "Let's practice \(exercise.title.lowercased()). This technique helps calm your nervous system by regulating your breath. Follow the guided breathing exercise that will appear next."
                let step = InstructionStep(
                    id: stepId,
                    instruction: explanation,
                    exerciseType: exercise.type,
                    exerciseTitle: exercise.title,
                    exerciseId: exercise.id,
                    promptType: .statement
                )
                steps.append(step)
                print("🔍 Added breathing explanation step: \(explanation)")
                stepId += 1
            } else {
                // For other exercise types, show all instructions as separate steps
                for (index, instruction) in exercise.instructions.enumerated() {
                    let promptType = index < exercise.instructionPromptTypes.count 
                        ? exercise.instructionPromptTypes[index] 
                        : .statement // Default to statement if no prompt type specified
                    
                    let step = InstructionStep(
                        id: stepId,
                        instruction: instruction,
                        exerciseType: exercise.type,
                        exerciseTitle: exercise.title,
                        exerciseId: exercise.id,
                        promptType: promptType
                    )
                    steps.append(step)
                    print("🔍 Added step \(stepId): \(instruction) (promptType: \(promptType))")
                    stepId += 1
                }
            }
        }
        
        instructionSteps = steps
        print("📝 Generated \(steps.count) instruction steps for level \(level.id)")
        for (index, step) in steps.enumerated() {
            print("📝 Step \(index + 1): \(step.instruction) - \(step.promptType)")
        }
    }
    
    private func startSession() {
        withAnimation(.easeInOut(duration: 0.6)) {
            currentPhase = .session
        }
    }
    
    private func handleStepCompletion(_ response: String?) {
        print("🔄 Step completed. Current: \(currentStepIndex), Total: \(totalSteps)")
        
        // Save user response if provided
        if let response = response, let step = currentStep {
            userResponses[step.id] = response
        }
        
        HapticFeedback.light()
        
        // Check if this is a breathing exercise instruction
        if let step = currentStep, step.exerciseType == .breathing {
            // For breathing exercises, show the breathing view after the instruction
            startBreathingExercise()
        } else {
            moveToNextStep()
        }
    }
    
    private func startBreathingExercise() {
        withAnimation(.easeInOut(duration: 0.6)) {
            showBreathingView = true
        }
    }
    
    private func handleBreathingCompletion() {
        print("🫁 Breathing exercise completed, moving to next step")
        print("🫁 Current step index: \(currentStepIndex), Total steps: \(totalSteps)")
        if let nextStep = currentStepIndex + 1 < instructionSteps.count ? instructionSteps[currentStepIndex + 1] : nil {
            print("🫁 Next step will be: \(nextStep.instruction) (type: \(nextStep.exerciseType))")
        }
        
        HapticFeedback.success()
        
        // Move to next step first, then hide breathing view
        moveToNextStep()
        
        // Hide breathing view after moving to next step
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showBreathingView = false
            }
        }
    }
    
    private func moveToNextStep() {
        print("🔄 Moving to next step. Current: \(currentStepIndex), Total: \(totalSteps), IsLast: \(isLastStep)")
        if isLastStep {
            print("✅ Last step completed, showing completion screen")
            completeSession()
        } else {
            print("➡️ Moving to next step: \(currentStepIndex + 1)")
            // Use a smoother transition with a slight delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    currentStepIndex += 1
                }
            }
        }
    }
    
    private func completeSession() {
        print("🎉 Completing session for level \(level.id)")
        // Mark level as completed
        onLevelCompleted(level.id)
        
        withAnimation(.easeInOut(duration: 0.6)) {
            currentPhase = .completion
        }
        print("🎯 Session phase changed to completion")
    }
    
    private func repeatSession() {
        withAnimation(.easeInOut(duration: 0.6)) {
            currentPhase = .intro
            currentStepIndex = 0
            userResponses.removeAll()
        }
    }
    
    private func backToJourney() {
        dismiss()
    }
    
    private var levelIcon: String {
        switch level.id {
        case 1: return "🌬️"
        case 2: return "🧠"
        case 3: return "💭"
        case 4: return "🌱"
        case 5: return "💚"
        default: return "🌿"
        }
    }
}

#Preview {
    NavigationStack {
        CalmLevelSessionView(level: CalmJourneyDataStore.shared.levels[0], onLevelCompleted: { _ in })
    }
}
