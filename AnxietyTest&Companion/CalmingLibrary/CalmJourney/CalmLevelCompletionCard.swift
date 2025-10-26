//
//  CalmLevelCompletionCard.swift
//  AnxietyTest&Companion
//
//  Session completion screen with companion celebration and action buttons.
//

import SwiftUI

struct CalmLevelCompletionCard: View {
    let level: CalmLevel
    let onRepeatSession: () -> Void
    let onBackToJourney: () -> Void
    
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Celebration content
            VStack(spacing: 24) {
                Text("You've completed this calm step 🌿")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                CompanionFaceView(expression: .happy)
                    .frame(width: 120, height: 120)
                
                Text("Take a deep breath.\nYou're doing great.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 16) {
                Button(action: {
                    HapticFeedback.light()
                    onBackToJourney()
                }) {
                    HStack {
                        Image(systemName: "house.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Back to Journey")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(Color(hex: "#6E63A4"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(radius: 3)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                
                Button(action: {
                    HapticFeedback.light()
                    onRepeatSession()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Repeat Session")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 50)
        }
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
        .onAppear {
            HapticFeedback.success()
            withAnimation(.easeInOut(duration: 0.6)) {
                isVisible = true
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
        
        CalmLevelCompletionCard(
            level: CalmJourneyDataStore.shared.levels[0],
            onRepeatSession: {},
            onBackToJourney: {}
        )
    }
}
