//
//  HapticManager.swift
//  AnxietyTest&Companion
//
//  Created by Mehmet Ali Kısacık on 26.10.2025.
//

import UIKit
import SwiftUI

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    // Soft haptic for gentle presence confirmation
    func soft() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
        impactFeedback.impactOccurred()
    }
    
    // Light haptic for subtle button responses
    func light() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    // Rigid haptic for grounding between steps
    func rigid() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .rigid)
        impactFeedback.impactOccurred()
    }
    
    // Success haptic for positive reinforcement
    func success() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    // Warning haptic for gentle alerts
    func warning() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
    }
}

// SwiftUI convenience wrapper
struct HapticFeedback {
    static func soft() { HapticManager.shared.soft() }
    static func light() { HapticManager.shared.light() }
    static func rigid() { HapticManager.shared.rigid() }
    static func success() { HapticManager.shared.success() }
    static func warning() { HapticManager.shared.warning() }
}
