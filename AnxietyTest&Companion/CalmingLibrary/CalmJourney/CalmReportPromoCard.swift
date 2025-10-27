//
//  CalmReportPromoCard.swift
//  AnxietyTest&Companion
//
//  Promotional card explaining the personalized report feature
//

import SwiftUI

struct CalmReportPromoCard: View {
    let level: CalmLevel
    let isPremiumUser: Bool
    let isCompleted: Bool
    let onViewReport: () -> Void
    let onShowPaywall: () -> Void
    let onClose: () -> Void
    
    @State private var isVisible = false
    
    private var isMilestoneLevel: Bool {
        return level.id == 5 || level.id == 10
    }
    
    private var milestoneText: String {
        if isCompleted {
            if level.id == 5 {
                return "You've completed the first 5 levels! 🌿"
            } else {
                return "You've completed all 10 levels! 🌿"
            }
        } else {
            if level.id == 5 {
                return "Complete the first 5 levels to unlock your report! 🌿"
            } else {
                return "Complete all 10 levels to unlock your report! 🌿"
            }
        }
    }
    
    private var reportDescription: String {
        if isCompleted {
            if level.id == 5 {
                return "Your personalized report is ready! It will analyze your emotional growth from the first 5 levels and provide insights into your progress with anxiety management."
            } else {
                return "Your comprehensive report is ready! It will reflect on your entire Calm Journey, from initial awareness to building lasting calm habits and finding purpose."
            }
        } else {
            if level.id == 5 {
                return "Complete levels 1-5 to unlock your personalized report. This will analyze your emotional growth and provide insights into your progress."
            } else {
                return "Complete all 10 levels to unlock your comprehensive report. This will reflect on your entire journey and celebrate your growth."
            }
        }
    }
    
    private var actionText: String {
        if isCompleted {
            if isPremiumUser {
                return "Generate Report"
            } else {
                return "Unlock Premium"
            }
        } else {
            if level.id == 5 {
                return "Complete Levels 1-5"
            } else {
                return "Complete All Levels"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side - Text content
            VStack(alignment: .leading, spacing: 6) {
                Text(milestoneText)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Text(reportDescription)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Right side - Companion and action
            VStack(spacing: 8) {
                // Companion face with subtle background effect
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 70, height: 70)
                    
                    CompanionFaceView(expression: isCompleted ? .happy : .neutral)
                        .frame(width: 30, height: 30)
                }
                
                // Action text
                Text(actionText)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#6E63A4"), Color(hex: "#B5A7E0")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: Color(hex: "#6E63A4").opacity(0.3), radius: 8, x: 0, y: 4)
        )
        .onTapGesture {
            HapticFeedback.light()
            print("CalmReportPromoCard tapped. isCompleted: \(isCompleted), isPremiumUser: \(isPremiumUser)")
            if isCompleted {
                if isPremiumUser {
                    print("Calling onViewReport")
                    onViewReport()
                } else {
                    print("Calling onShowPaywall")
                    onShowPaywall()
                }
            } else {
                print("Level not completed yet")
            }
        }
        .overlay(
            // Close button
            Button(action: {
                HapticFeedback.light()
                onClose()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.top, 8)
            .padding(.trailing, 8),
            alignment: .topTrailing
        )
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Color(hex: "#6E63A4"), Color(hex: "#B5A7E0")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        CalmReportPromoCard(
            level: CalmJourneyDataStore.shared.levels[4], // Level 5
            isPremiumUser: false,
            isCompleted: true,
            onViewReport: {},
            onShowPaywall: {},
            onClose: {}
        )
    }
}
