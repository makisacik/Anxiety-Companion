//
//  DailyTipView.swift
//  AnxietyTest&Companion
//
//  Created by Mehmet Ali Kısacık on 26.10.2025.
//

import SwiftUI

struct DailyTipView: View {
    @State private var currentTip: String = ""
    @State private var isVisible = false
    
    private let tips = [
        "Remember to take a slow, deep breath today.",
        "It's okay to take things one step at a time.",
        "You're doing better than you think you are.",
        "Small moments of peace add up to big changes.",
        "Your feelings are valid, and they will pass.",
        "Take a moment to notice something beautiful around you.",
        "Progress isn't always linear, and that's perfectly normal.",
        "You have the strength to handle whatever comes your way.",
        "Be gentle with yourself today.",
        "Every small step forward is worth celebrating.",
        "You are not alone in this journey.",
        "It's okay to rest when you need to.",
        "Your mental health matters just as much as your physical health.",
        "Tomorrow is a fresh start, but today is worth living too.",
        "You're allowed to feel however you feel right now."
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            if !currentTip.isEmpty {
                Text(currentTip)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 10)
                    .animation(.easeInOut(duration: 0.6), value: isVisible)
            }
        }
        .onAppear {
            loadDailyTip()
            withAnimation(.easeInOut(duration: 0.6).delay(0.3)) {
                isVisible = true
            }
        }
    }
    
    private func loadDailyTip() {
        // Use day of year to deterministically rotate tips
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let tipIndex = (dayOfYear - 1) % tips.count
        currentTip = tips[tipIndex]
    }
}

#Preview {
    VStack {
        DailyTipView()
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
