//
//  CompanionSectionView.swift
//  AnxietyTest&Companion
//
//  Created by Mehmet Ali Kısacık on 26.10.2025.
//

import SwiftUI

struct CompanionSectionView: View {
    let gad7Entries: [GAD7Entry]
    let moodEntries: [MoodEntry]
    
    @State private var companionScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 12) {
            CompanionFaceView(expression: currentExpression)
                .frame(width: 120, height: 120)
                .scaleEffect(companionScale)
                .shadow(color: Color.themeText.opacity(0.15), radius: 10, x: 0, y: 5)
                .onTapGesture {
                    HapticFeedback.soft()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        companionScale = 1.1
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            companionScale = 1.0
                        }
                    }
                }
            
            Text(companionMessage)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.themeText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .animation(.easeInOut(duration: 0.6), value: companionMessage)
        }
        .padding(.bottom, 10)
    }
    
    private var currentExpression: CompanionFaceView.Expression {
        guard let latestEntry = gad7Entries.first else { return .neutral }
        
        let score = Int(latestEntry.score)
        if score <= 4 {
            return .happy
        } else if score <= 9 {
            return .neutral
        } else {
            return .mouthLeft
        }
    }
    
    private var companionMessage: String {
        if gad7Entries.isEmpty {
            return "We'll start once you log your first check-in."
        }
        
        if gad7Entries.count == 1 {
            return "Great start! Keep tracking your progress."
        }
        
        // Compare last two entries for trend
        let sortedEntries = gad7Entries.sorted { $0.date ?? Date.distantPast < $1.date ?? Date.distantPast }
        guard sortedEntries.count >= 2 else { return "Keep building your journey." }
        
        let latest = Int(sortedEntries.last?.score ?? 0)
        let previous = Int(sortedEntries[sortedEntries.count - 2].score)
        
        if latest < previous {
            return "You're feeling calmer lately — nice work 🌿"
        } else if latest > previous {
            return "Ups and downs are part of growth."
        } else {
            return "You're showing great consistency."
        }
    }
}

#Preview {
    VStack {
        CompanionSectionView(gad7Entries: [], moodEntries: [])
        
        Spacer()
    }
    .padding()
    .background(Color.themeBackground)
}
