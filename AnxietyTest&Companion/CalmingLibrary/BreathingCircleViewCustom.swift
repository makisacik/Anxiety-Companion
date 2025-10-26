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
                .strokeBorder(Color.white.opacity(0.5), lineWidth: 4)
                .frame(width: isExpanded ? 200 : 120,
                       height: isExpanded ? 200 : 120)
                .animation(.easeInOut(duration: inhaleDuration), value: isExpanded)

            // Inner circle (main breathing circle)
            Circle()
                .fill(LinearGradient(
                    colors: [Color(hex: "#B5A7E0"), Color(hex: "#6E63A4")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing))
                .frame(width: isExpanded ? 180 : 100,
                       height: isExpanded ? 180 : 100)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                .animation(.easeInOut(duration: inhaleDuration), value: isExpanded)

            VStack {
                Text(phaseLabel)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.top, 10)
                Text("Cycle \(cycleCount)/5")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
            }
            .offset(y: 150)
        }
        .onAppear { startBreathingCycle() }
        .onDisappear { isActive = false }
    }

    private var phaseLabel: String {
        switch phase {
        case .inhale: return "Inhale..."
        case .hold: return "Hold..."
        case .exhale: return "Exhale..."
        case .end: return "Finished 🌿"
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
