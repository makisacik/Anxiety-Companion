//
//  ConfigurableBreathingCircleView.swift
//  AnxietyTest&Companion
//
//  Animated breathing guide with configurable timing parameters.
//

import SwiftUI

struct ConfigurableBreathingCircleView: View {
    @Binding var isExpanded: Bool
    let exerciseType: BreathingExerciseType
    let totalCycles: Int
    var onPhaseChange: (String) -> Void
    var onComplete: () -> Void

    @State private var phase: BreathingPhase = .inhale
    @State private var cycleCount = 0
    @State private var isActive = true

    enum BreathingPhase {
        case inhale, hold, exhale, holdAfterExhale, end
    }

    var body: some View {
        ZStack {
            // Outer circle (border)
            Circle()
                .strokeBorder(Color.themeText.opacity(0.3), lineWidth: 4)
                .frame(width: isExpanded ? 220 : 120,
                       height: isExpanded ? 220 : 120)
                .animation(.easeInOut(duration: exerciseType.inhaleDuration), value: isExpanded)

            // Inner circle (main breathing circle)
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.themeCompanionDark, Color.themeCompanionMid],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: isExpanded ? 200 : 100,
                       height: isExpanded ? 200 : 100)
                .clipShape(Circle())
                .shadow(color: Color.themeText.opacity(0.15), radius: 8, x: 0, y: 4)
                .animation(.easeInOut(duration: exerciseType.inhaleDuration), value: isExpanded)

            VStack(spacing: 4) {
                Text(phaseLabel)
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.themeText)
                
                Text("Cycle \(cycleCount)/\(totalCycles)")
                    .font(.footnote)
                    .foregroundColor(.themeText.opacity(0.7))
            }
            .offset(y: 160)
        }
        .onAppear { startBreathingCycle() }
        .onDisappear { isActive = false }
    }

    private var phaseLabel: String {
        switch phase {
        case .inhale: return "Inhale..."
        case .hold: return "Hold..."
        case .exhale: return "Exhale..."
        case .holdAfterExhale: return "Hold..."
        case .end: return "Finished 🌿"
        }
    }

    // MARK: - Core Animation Loop
    private func startBreathingCycle() {
        guard isActive else { return }

        // Inhale phase
        phase = .inhale
        onPhaseChange("inhale")
        withAnimation(.easeInOut(duration: exerciseType.inhaleDuration)) {
            isExpanded = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + exerciseType.inhaleDuration) {
            guard isActive else { return }

            // Hold phase (if applicable)
            if exerciseType.holdDuration > 0 {
                phase = .hold
                onPhaseChange("hold")

                DispatchQueue.main.asyncAfter(deadline: .now() + exerciseType.holdDuration) {
                    guard isActive else { return }
                    moveToExhale()
                }
            } else {
                moveToExhale()
            }
        }
    }

    private func moveToExhale() {
        // Exhale phase
        phase = .exhale
        onPhaseChange("exhale")
        withAnimation(.easeInOut(duration: exerciseType.exhaleDuration)) {
            isExpanded = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + exerciseType.exhaleDuration) {
            guard isActive else { return }

            // Hold after exhale phase (if applicable)
            if exerciseType.holdAfterExhaleDuration > 0 {
                phase = .holdAfterExhale
                onPhaseChange("hold")

                DispatchQueue.main.asyncAfter(deadline: .now() + exerciseType.holdAfterExhaleDuration) {
                    guard isActive else { return }
                    completeCycle()
                }
            } else {
                completeCycle()
            }
        }
    }

    private func completeCycle() {
        cycleCount += 1
        if cycleCount >= totalCycles {
            phase = .end
            onPhaseChange("end")
            onComplete()
        } else {
            startBreathingCycle()
        }
    }
}
