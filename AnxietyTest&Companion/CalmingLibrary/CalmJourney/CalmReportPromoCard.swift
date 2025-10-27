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
                return "Levels 1-5 complete. 🌿"
            } else {
                return "All 10 levels complete. 🌿"
            }
        } else {
            if level.id == 5 {
                return "Finish 1-5 to unlock your report."
            } else {
                return "Finish all 10 to unlock your report."
            }
        }
    }
    
    private var reportDescription: String {
        if isCompleted {
            if level.id == 5 {
                return "Your mid-journey summary is ready with quick insights on the first five steps."
            } else {
                return "Your full journey story is ready with highlights from every level."
            }
        } else {
            if level.id == 5 {
                return "Wrap levels 1-5 to unlock a snapshot of your progress."
            } else {
                return "Complete the path to see your full calm report."
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
                // Companion face with subtle background effect - positioned to overflow
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .fill(Color.white.opacity(0.1))
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
            onShowPaywall: {}
        )
    }
}
