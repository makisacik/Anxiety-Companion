//
//  SummaryCardView.swift
//  AnxietyTest&Companion
//
//  Created by Mehmet Ali Kısacık on 26.10.2025.
//

import SwiftUI

struct SummaryCardView: View {
    let gad7Entries: [GAD7Entry]
    
    @State private var showPulse = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(String(localized: "summary_recent_checkin"))
                    .font(.system(.title2, design: .serif))
                    .fontWeight(.semibold)
                    .foregroundColor(.themeText)
                
                Spacer()
                
                if let latestEntry = gad7Entries.first {
                    CircularProgressView(score: Int(latestEntry.score), maxScore: 21)
                        .scaleEffect(showPulse ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.6).repeatCount(3, autoreverses: true), value: showPulse)
                }
            }
            
            if let latestEntry = gad7Entries.first {
                let daysAgo = Calendar.current.dateComponents([.day], from: latestEntry.date ?? Date(), to: Date()).day ?? 0
                let category = getScoreCategory(Int(latestEntry.score))
                let daysAgoText = daysAgo == 0 ? String(localized: "home_anxiety_last_test_today") : String.localizedStringWithFormat(String(localized: "home_anxiety_last_test_days_ago"), daysAgo)
                
                Text(String.localizedStringWithFormat(String(localized: "summary_last_test_format"), daysAgoText, category, Int(latestEntry.score)))
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.themeText.opacity(0.7))
            } else {
                Text(String(localized: "summary_no_checkin"))
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.themeText.opacity(0.7))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.themeCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.themeDivider, lineWidth: 1)
                )
        )
        .onAppear {
            // Show pulse animation if there's a recent entry (within last 24 hours)
            if let latestEntry = gad7Entries.first,
               let entryDate = latestEntry.date,
               Calendar.current.isDate(entryDate, inSameDayAs: Date()) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showPulse = true
                }
            }
        }
    }
    
    private func getScoreCategory(_ score: Int) -> String {
        switch score {
        case 0...4: return String(localized: "home_anxiety_score_minimal")
        case 5...9: return String(localized: "home_anxiety_score_mild")
        case 10...14: return String(localized: "home_anxiety_score_moderate")
        default: return String(localized: "home_anxiety_score_severe")
        }
    }
}

#Preview {
    VStack {
        SummaryCardView(gad7Entries: [])
        
        Spacer()
    }
    .padding()
    .background(Color.themeBackground)
}
