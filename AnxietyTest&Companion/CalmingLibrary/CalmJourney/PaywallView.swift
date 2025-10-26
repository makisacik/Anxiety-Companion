//
//  PaywallView.swift
//  AnxietyTest&Companion
//
//  Simple premium upgrade modal for Calm Journey levels 2-5.
//

import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isPremiumUser") private var isPremiumUser = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "#6E63A4"), Color(hex: "#B5A7E0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Icon
                VStack(spacing: 16) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .padding(30)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.2))
                        )
                    
                    Text("Unlock Your Next Calm Levels 🌿")
                        .font(.system(.largeTitle, design: .serif))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                
                // Benefits
                VStack(spacing: 20) {
                    benefitRow(
                        icon: "brain.head.profile",
                        title: "Understand Anxiety",
                        description: "Learn why anxiety appears and how to interrupt the cycle"
                    )
                    
                    benefitRow(
                        icon: "lightbulb.fill",
                        title: "Thought Awareness",
                        description: "Master techniques to observe and reframe anxious thoughts"
                    )
                    
                    benefitRow(
                        icon: "heart.fill",
                        title: "Build Calm Habits",
                        description: "Create routines that support lasting mental balance"
                    )
                    
                    benefitRow(
                        icon: "hands.sparkles.fill",
                        title: "Self-Compassion",
                        description: "Learn to be kind to yourself and maintain emotional wellness"
                    )
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 16) {
                    // Upgrade button (mock)
                    Button(action: {
                        // Mock upgrade - just set premium to true for testing
                        isPremiumUser = true
                        HapticFeedback.success()
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Upgrade to Premium")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(Color(hex: "#6E63A4"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.white)
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    // Dismiss button
                    Button(action: {
                        HapticFeedback.light()
                        dismiss()
                    }) {
                        Text("Maybe Later")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
    }
    
    private func benefitRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color(hex: "#B5A7E0"))
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    PaywallView()
}
