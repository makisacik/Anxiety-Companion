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
    @State private var hasStartedPractice = false
    
    var body: some View {
        ZStack {
            if hasStartedPractice {
                practiceView
            } else {
                introView
            }
        }
        .navigationTitle("Breathing Exercise")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbarBackground(Color.themeBackground, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
    }
    
    private var introView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Icon
                Image(systemName: "lungs.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.themeText)
                    .padding(20)
                    .background(
                        Circle()
                            .fill(Color.themeCard)
                    )
                    .padding(.top, 20)

                // Title
                Text(exercise.title)
                    .font(.system(.title, design: .serif))
                    .fontWeight(.bold)
                    .foregroundColor(.themeText)
                    .multilineTextAlignment(.center)

                // Instructions
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, instruction in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(index + 1)")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(.themeText)
                                .frame(width: 20, height: 20)
                                .background(
                                    Circle()
                                        .fill(Color.themeCard)
                                )

                            Text(instruction)
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(.themeText.opacity(0.8))
                                .fixedSize(horizontal: false, vertical: true)

                            Spacer()
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.themeCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.themeDivider, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)

                // Science note
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 18))
                            .foregroundColor(.themeText)
                        
                        Text("The Science")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.themeText)
                        
                        Spacer()
                    }
                    
                    Text(exercise.scienceNote)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.themeText.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.themeCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.themeDivider, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)

                // Start Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        hasStartedPractice = true
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
                    .foregroundColor(.themeText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.themeCard)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 100) // Extra padding to ensure button is above tab bar
            }
        }
    }
    
    private var practiceView: some View {
        ScrollView {
            VStack(spacing: 28) {
                Spacer(minLength: 20)

                CompanionFaceView(expression: .calm)
                    .frame(width: 140, height: 140)

                Text("Take five rounds at your own pace.")
                    .font(.system(.title3, design: .rounded).bold())
                    .foregroundColor(.themeText)
                    .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 14) {
                    practiceStep(number: 1, text: "Inhale gently for four counts.")
                    practiceStep(number: 2, text: "Pause for four counts.")
                    practiceStep(number: 3, text: "Exhale slowly for four counts.")
                    practiceStep(number: 4, text: "Pause again before the next cycle.")
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.themeCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.themeDivider, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)

                Button(action: {
                    HapticFeedback.success()
                    onComplete()
                }) {
                    Text("Continue →")
                        .font(.system(.body, design: .rounded).bold())
                        .foregroundColor(.themeText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.themeCard)
                        )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.bottom, 60)
            }
        }
    }

    private func practiceStep(number: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.system(.body, design: .rounded).bold())
                .foregroundColor(.themeText)
                .frame(width: 22, height: 22)
                .background(
                    Circle()
                        .fill(Color.themeCard)
                )

            Text(text)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.themeText.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
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
