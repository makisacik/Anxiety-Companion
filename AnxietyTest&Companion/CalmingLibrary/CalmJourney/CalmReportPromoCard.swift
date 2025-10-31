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
    
    private var milestoneText: String {
        if isCompleted {
            if level.id == 5 {
                return String(localized: "report_promo_levels_1_5_complete")
            } else {
                return String(localized: "report_promo_all_levels_complete")
            }
        } else {
            if level.id == 5 {
                return String(localized: "report_promo_finish_1_5")
            } else {
                return String(localized: "report_promo_finish_all_10")
            }
        }
    }
    
    private var reportDescription: String {
        if isCompleted {
            if level.id == 5 {
                return String(localized: "report_promo_desc_mid_journey")
            } else {
                return String(localized: "report_promo_desc_full_journey")
            }
        } else {
            if level.id == 5 {
                return String(localized: "report_promo_desc_unlock_mid")
            } else {
                return String(localized: "report_promo_desc_unlock_full")
            }
        }
    }

    private var statusIcon: String {
        if isCompleted {
            return isPremiumUser ? "chevron.right" : "lock.fill"
        }
        return "circle.dashed"
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side - Text content
            VStack(alignment: .leading, spacing: 6) {
                Text(milestoneText)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.themeText)
                    .multilineTextAlignment(.leading)
                
                Text(reportDescription)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.themeText.opacity(0.8))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Right side - Companion and action
            VStack(spacing: 8) {
                // Companion face with subtle background effect - positioned to overflow
                ZStack {
                    Circle()
                        .fill(Color.themeDivider.opacity(0.4))
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .fill(Color.themeDivider.opacity(0.2))
                        .frame(width: 70, height: 70)
                    
                    CompanionFaceView(
                        expression: isCompleted ? .happy : .neutral,
                        animateBreathing: false
                    )
                        .frame(width: 90, height: 90)
                }
                .offset(x: 20)
                .offset(y: -10)
                // Push it to the right to overflow
                .frame(width: 70, height: 70) // Constrain layout space
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.themeCard)
                .shadow(color: Color.themeText.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .onTapGesture {
            HapticFeedback.light()
            print("CalmReportPromoCard tapped. isCompleted: \(isCompleted), isPremiumUser: \(isPremiumUser)")
            
            // Always handle tap in parent view
            if !isPremiumUser {
                print("Calling onShowPaywall")
                onShowPaywall()
            } else {
                print("Calling onViewReport")
                onViewReport()
            }
        }
    }
}

#Preview {
    ZStack {
        Color.themeBackground
            .ignoresSafeArea()
        
        CalmReportPromoCard(
            level: CalmJourneyDataStore.shared.levels[4], // Level 5
            isPremiumUser: false,
            isCompleted: true,
            onViewReport: {},
            onShowPaywall: {}
        )
    }
}
