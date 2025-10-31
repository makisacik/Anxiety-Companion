//
//  BreathingExerciseType.swift
//  AnxietyTest&Companion
//
//  Created by GitHub Copilot on 28.10.2025.
//

import Foundation
import SwiftUI

enum BreathingExerciseType: String, CaseIterable, Identifiable {
    case boxBreathing = "boxBreathing"
    case fourSevenEight = "fourSevenEight"
    case calmFlow = "calmFlow"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .boxBreathing:
            return String(localized: "breathing_type_box_breathing")
        case .fourSevenEight:
            return String(localized: "breathing_type_478_breathing")
        case .calmFlow:
            return String(localized: "breathing_type_calm_flow")
        }
    }
    
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
            return String(localized: "breathing_desc_box_breathing")
        case .fourSevenEight:
            return String(localized: "breathing_desc_478_breathing")
        case .calmFlow:
            return String(localized: "breathing_desc_calm_flow")
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
