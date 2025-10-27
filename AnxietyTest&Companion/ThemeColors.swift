//
//  ThemeColors.swift
//  AnxietyTest&Companion
//
//  Created by Mehmet Ali Kısacık on 27.10.2025.
//

import SwiftUI

extension Color {
    // MARK: - Main Theme Colors
    
    /// #FFFFFF – #FAFAFA: Background / page base
    static let themeBackground = Color(hex: "#FAFAFA")
    static let themeBackgroundPure = Color(hex: "#FFFFFF")
    
    /// #E8E8E8: Cards and containers
    static let themeCard = Color(hex: "#E8E8E8")
    
    /// #C0C0C0: Dividers and inactive states
    static let themeDivider = Color(hex: "#C0C0C0")
    
    /// #6E6E6E: Text or important outlines
    static let themeText = Color(hex: "#6E6E6E")
    
    /// #2C2C2C: Companion outlines / stickman lines
    static let themeCompanionOutline = Color(hex: "#2C2C2C")
    
    // MARK: - Companion Gradient Colors (similar to original purple gradient)
    /// Soft light tone for companion gradient
    static let themeCompanionLight = Color(hex: "#D4D4D4")
    /// Main tone for companion gradient
    static let themeCompanionMid = Color(hex: "#A8A8A8")
    /// Deeper tone for companion gradient
    static let themeCompanionDark = Color(hex: "#8C8C8C")
}

// MARK: - Force Light Mode View Modifier
struct ForceLightMode: ViewModifier {
    func body(content: Content) -> some View {
        content
            .preferredColorScheme(.light)
    }
}

extension View {
    func forceLightMode() -> some View {
        modifier(ForceLightMode())
    }
}
