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
    @Published var isFinished = false
    private var cycleCount = 0

    func updatePhase(_ phase: String) {
        DispatchQueue.main.async {
            switch phase {
            case "inhale":
                HapticManager.shared.soft()

            case "hold":
                HapticManager.shared.light()

            case "exhale":
                HapticManager.shared.soft()

            case "end":
                // This is called once after all 5 cycles are complete
                self.isFinished = true
                HapticManager.shared.success()

            default: break
            }
        }
    }

    func finishSession() {
        self.isFinished = true
    }
}
