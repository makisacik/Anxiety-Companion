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
                Text("Your Recent Check-In")
                    .font(.system(.title2, design: .serif))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
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
                
                Text("Last test: \(daysAgo == 0 ? "Today" : "\(daysAgo) days ago") • Score: \(category) (\(latestEntry.score)/21)")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            } else {
                Text("You haven't done a check-in yet.")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
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
        case 0...4: return "Minimal"
        case 5...9: return "Mild"
        case 10...14: return "Moderate"
        default: return "Severe"
        }
    }
}

#Preview {
    VStack {
        SummaryCardView(gad7Entries: [])
        
        Spacer()
    }
    .padding()
    .background(
        LinearGradient(
            colors: [Color(hex: "#6E63A4"), Color(hex: "#B5A7E0")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
