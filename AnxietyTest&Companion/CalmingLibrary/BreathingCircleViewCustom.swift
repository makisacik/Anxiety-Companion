//
//  BreathingCircleViewCustom.swift
//  AnxietyTest&Companion
//
//  Animated breathing guide synced with companion dialogue.
//

import SwiftUI

struct BreathingCircleViewCustom: View {
    @Binding var isExpanded: Bool
    var onPhaseChange: (String) -> Void

    @State private var phase: BreathingPhase = .inhale
    @State private var cycleCount = 0
    @State private var isActive = true

    // durations in seconds
    private let inhaleDuration: Double = 4
    private let holdDuration: Double = 2
    private let exhaleDuration: Double = 4

    enum BreathingPhase {
        case inhale, hold, exhale, end
    }

    var body: some View {
        ZStack {
            // Outer circle (border)
            Circle()
                .strokeBorder(Color.themeText.opacity(0.3), lineWidth: 4)
                .frame(width: isExpanded ? 200 : 120,
                       height: isExpanded ? 200 : 120)
                .animation(.easeInOut(duration: inhaleDuration), value: isExpanded)

            // Inner circle (main breathing circle)
            Circle()
                .fill(LinearGradient(
                    colors: [Color.themeCompanionDark, Color.themeCompanionMid],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing))
                .frame(width: isExpanded ? 180 : 100,
                       height: isExpanded ? 180 : 100)
                .clipShape(Circle())
                .shadow(color: Color.themeText.opacity(0.15), radius: 8, x: 0, y: 4)
                .animation(.easeInOut(duration: inhaleDuration), value: isExpanded)

            VStack {
                Text(phaseLabel)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.themeText)
                    .padding(.top, 10)
                Text(String.localizedStringWithFormat(String(localized: "breathing_circle_cycle"), cycleCount))
                    .font(.footnote)
                    .foregroundColor(.themeText.opacity(0.7))
            }
            .offset(y: 150)
        }
        .onAppear { startBreathingCycle() }
        .onDisappear { isActive = false }
    }

    private var phaseLabel: String {
        switch phase {
        case .inhale: return String(localized: "breathing_phase_inhale")
        case .hold: return String(localized: "breathing_phase_hold")
        case .exhale: return String(localized: "breathing_phase_exhale")
        case .end: return String(localized: "breathing_phase_finished")
        }
    }

    // MARK: - Core Animation Loop
    private func startBreathingCycle() {
        guard isActive else { return }

        phase = .inhale
        onPhaseChange("inhale")
        withAnimation(.easeInOut(duration: inhaleDuration)) {
            isExpanded = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + inhaleDuration) {
            guard isActive else { return }

            phase = .hold
            onPhaseChange("hold")

            DispatchQueue.main.asyncAfter(deadline: .now() + holdDuration) {
                guard isActive else { return }

                phase = .exhale
                onPhaseChange("exhale")
                withAnimation(.easeInOut(duration: exhaleDuration)) {
                    isExpanded = false
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + exhaleDuration) {
                    guard isActive else { return }

                    cycleCount += 1
                    if cycleCount >= 5 {
                        phase = .end
                        onPhaseChange("end")
                    } else {
                        startBreathingCycle()
                    }
                }
            }
        }
    }
}
