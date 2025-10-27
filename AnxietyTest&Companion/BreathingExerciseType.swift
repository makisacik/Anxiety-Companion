//
//  BreathingExerciseType.swift
//  AnxietyTest&Companion
//
//  Created by GitHub Copilot on 28.10.2025.
//

import Foundation
import SwiftUI

enum BreathingExerciseType: String, CaseIterable, Identifiable {
    case boxBreathing = "Box Breathing"
    case fourSevenEight = "4-7-8 Breathing"
    case calmFlow = "Calm Flow"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .boxBreathing:
            return "square.on.square"
        case .fourSevenEight:
            return "waveform.path.ecg"
        case .calmFlow:
            return "wind"
        }
    }
    
    var description: String {
        switch self {
        case .boxBreathing:
            return "Inhale, hold, exhale, hold — all for 4 counts. A balanced rhythm for focus."
        case .fourSevenEight:
            return "Inhale for 4, hold for 7, exhale for 8. Deeply calming, great before sleep."
        case .calmFlow:
            return "Inhale for 4, exhale for 6. Gentle and soothing for everyday calm."
        }
    }
    
    var inhaleDuration: Double {
        switch self {
        case .boxBreathing:
            return 4
        case .fourSevenEight:
            return 4
        case .calmFlow:
            return 4
        }
    }
    
    var holdDuration: Double {
        switch self {
        case .boxBreathing:
            return 4
        case .fourSevenEight:
            return 7
        case .calmFlow:
            return 0 // no hold
        }
    }
    
    var exhaleDuration: Double {
        switch self {
        case .boxBreathing:
            return 4
        case .fourSevenEight:
            return 8
        case .calmFlow:
            return 6
        }
    }
    
    var holdAfterExhaleDuration: Double {
        switch self {
        case .boxBreathing:
            return 4
        case .fourSevenEight:
            return 0
        case .calmFlow:
            return 0
        }
    }
}
