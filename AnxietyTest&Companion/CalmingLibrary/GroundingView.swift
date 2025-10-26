//
//  GroundingView.swift
//  AnxietyTest&Companion
//
//  Interactive 5-4-3-2-1 grounding technique with step-by-step guidance.
//

import SwiftUI

struct GroundingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0
    @State private var showSuccessMessage = false
    @State private var startTime = Date()
    @State private var showGroundingExercise = false
    
    // Response arrays for each step
    @State private var seeResponses = Array(repeating: "", count: 5)
    @State private var hearResponses = Array(repeating: "", count: 4)
    @State private var touchResponses = Array(repeating: "", count: 3)
    @State private var smellResponses = Array(repeating: "", count: 2)
    @State private var tasteResponse = ""
    
    private let steps = [
        GroundingStep(title: "5 Things You See", description: "Look around and name 5 things you can see", count: 5, emoji: "👁️"),
        GroundingStep(title: "4 Things You Hear", description: "Listen carefully and name 4 things you can hear", count: 4, emoji: "👂"),
        GroundingStep(title: "3 Things You Touch", description: "Feel around and name 3 things you can touch", count: 3, emoji: "✋"),
        GroundingStep(title: "2 Things You Smell", description: "Take a deep breath and name 2 things you can smell", count: 2, emoji: "👃"),
        GroundingStep(title: "1 Thing You Taste", description: "Notice and name 1 thing you can taste", count: 1, emoji: "👅")
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#6E63A4"), Color(hex: "#B5A7E0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if !showGroundingExercise {
                introView
            } else {
                groundingExerciseView
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .medium))
                }
            }
        }
    }

    private var introView: some View {
        VStack(spacing: 30) {
            Spacer()

            // Icon
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 60))
                .foregroundColor(.white)
                .padding(30)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.2))
                )

            // Title
            Text("5-4-3-2-1 Grounding")
                .font(.system(.largeTitle, design: .serif))
                .fontWeight(.bold)
                .foregroundColor(.white)

            // Scientific explanation
            VStack(spacing: 16) {
                benefitRow(
                    icon: "cross.case.fill",
                    title: "Reduces Panic Symptoms",
                    description: "Grounding techniques help interrupt anxious thought patterns and shift focus to your immediate environment."
                )

                benefitRow(
                    icon: "eye.fill",
                    title: "Engages Your Senses",
                    description: "By using all five senses, you activate different parts of your brain, helping you feel more present and anchored."
                )

                benefitRow(
                    icon: "arrow.counterclockwise",
                    title: "Breaks Anxiety Cycles",
                    description: "This technique disrupts the anxiety loop by redirecting your attention to concrete, observable things in your environment."
                )
            }
            .padding(.horizontal, 30)

            Spacer()

            // Start Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showGroundingExercise = true
                }
                HapticManager.shared.soft()
            }) {
                HStack {
                    Image(systemName: "play.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Start Grounding Exercise")
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
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
    }

    private func benefitRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color(hex: "#B5A7E0"))
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var groundingExerciseView: some View {
        VStack(spacing: 24) {
            // Progress indicator
            HStack {
                ForEach(0..<steps.count, id: \.self) { index in
                    Circle()
                        .fill(index <= currentStep ? Color.white : Color.white.opacity(0.3))
                        .frame(width: 12, height: 12)
                        .animation(.easeInOut, value: currentStep)
                }
            }
            .padding(.top, 20)
            
            // Current step content
            VStack(spacing: 20) {
                Text(steps[currentStep].emoji)
                    .font(.system(size: 60))
                
                Text(steps[currentStep].title)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(steps[currentStep].description)
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Input fields for current step
                inputFieldsForCurrentStep
            }
            
            Spacer()
            
            // Navigation buttons
            HStack(spacing: 20) {
                if currentStep > 0 {
                    Button("Previous") {
                        withAnimation(.easeInOut) {
                            currentStep -= 1
                        }
                        HapticManager.shared.light()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(25)
                    .foregroundColor(.white)
                }
                
                Spacer()
                
                Button(currentStep == steps.count - 1 ? "Complete" : "Next") {
                    if currentStep == steps.count - 1 {
                        completeGrounding()
                    } else {
                        withAnimation(.easeInOut) {
                            currentStep += 1
                        }
                        HapticManager.shared.light()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(hex: "#B5A7E0"))
                .cornerRadius(25)
                .foregroundColor(.white)
                .disabled(!isCurrentStepValid)
                .opacity(isCurrentStepValid ? 1 : 0.6)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .overlay(
            // Success overlay
            Group {
                if showSuccessMessage {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            dismiss()
                        }
                    
                    VStack(spacing: 20) {
                        Text("🌿")
                            .font(.system(size: 60))
                        
                        Text("Well Done!")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                        
                        Text("You've completed the grounding exercise. Take a moment to notice how you feel.")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(40)
                    .background(Color(hex: "#6E63A4").opacity(0.95))
                    .cornerRadius(20)
                    .padding(.horizontal, 24)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        )
        .onAppear {
            startTime = Date()
        }
    }
    
    @ViewBuilder
    private var inputFieldsForCurrentStep: some View {
        VStack(spacing: 12) {
            switch currentStep {
            case 0: // See
                ForEach(0..<5, id: \.self) { index in
                    TextField("Thing \(index + 1) you see", text: $seeResponses[index])
                        .textFieldStyle(GroundingTextFieldStyle())
                }
            case 1: // Hear
                ForEach(0..<4, id: \.self) { index in
                    TextField("Thing \(index + 1) you hear", text: $hearResponses[index])
                        .textFieldStyle(GroundingTextFieldStyle())
                }
            case 2: // Touch
                ForEach(0..<3, id: \.self) { index in
                    TextField("Thing \(index + 1) you touch", text: $touchResponses[index])
                        .textFieldStyle(GroundingTextFieldStyle())
                }
            case 3: // Smell
                ForEach(0..<2, id: \.self) { index in
                    TextField("Thing \(index + 1) you smell", text: $smellResponses[index])
                        .textFieldStyle(GroundingTextFieldStyle())
                }
            case 4: // Taste
                TextField("Thing you taste", text: $tasteResponse)
                    .textFieldStyle(GroundingTextFieldStyle())
            default:
                EmptyView()
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var isCurrentStepValid: Bool {
        switch currentStep {
        case 0: return seeResponses.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        case 1: return hearResponses.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        case 2: return touchResponses.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        case 3: return smellResponses.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        case 4: return !tasteResponse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        default: return false
        }
    }
    
    private func completeGrounding() {
        let duration = Int(Date().timeIntervalSince(startTime))
        
        // Save to CoreData
        DataManager.shared.saveGroundingResponse(
            seeResponses: seeResponses,
            hearResponses: hearResponses,
            touchResponses: touchResponses,
            smellResponses: smellResponses,
            tasteResponse: tasteResponse
        )
        
        // Save activity completion
        DataManager.shared.saveActivityCompletion(
            activityTitle: "Grounding",
            duration: duration
        )
        
        HapticManager.shared.success()
        
        withAnimation(.easeInOut(duration: 0.5)) {
            showSuccessMessage = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            dismiss()
        }
    }
}

struct GroundingStep {
    let title: String
    let description: String
    let count: Int
    let emoji: String
}

struct GroundingTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.2))
            .cornerRadius(12)
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
    }
}

#Preview {
    NavigationStack {
        GroundingView()
    }
}
