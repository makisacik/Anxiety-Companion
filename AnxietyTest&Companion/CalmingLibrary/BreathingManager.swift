//
//  BreathingManager.swift
//  AnxietyTest&Companion
//
//  Controls breathing session timing and companion synchronization.
//

import Foundation
import SwiftUI
import Combine

final class BreathingManager: ObservableObject {
    @Published var isExpanded = false
    @Published var currentDialogue = "Let's take a few calm breaths together 🌿"
    @Published var currentExpression: CompanionFaceView.Expression = .neutral
    @Published var isFinished = false
    private var cycleCount = 0

    func updatePhase(_ phase: String) {
        DispatchQueue.main.async {
            switch phase {
            case "inhale":
                self.currentDialogue = "Breathe in slowly..."
                self.currentExpression = .calm
                HapticManager.shared.soft()

            case "hold":
                self.currentDialogue = "Hold it gently..."
                self.currentExpression = .neutral
                HapticManager.shared.light()

            case "exhale":
                self.currentDialogue = "Let it go..."
                self.currentExpression = .smile
                HapticManager.shared.soft()

            case "end":
                self.cycleCount += 1
                if self.cycleCount >= 5 {
                    self.currentDialogue = "Beautiful work 🌿"
                    self.currentExpression = .happy
                    self.isFinished = true
                    HapticManager.shared.success()
                } else {
                    self.currentDialogue = "Ready for the next breath..."
                }

            default: break
            }
        }
    }

    func finishSession() {
        self.isFinished = true
    }
}
