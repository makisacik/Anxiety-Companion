//
//  IntroOverlayView.swift
//  AnxietyTest&Companion
//
//  Created by Mehmet Ali Kısacık on 26.10.2025.
//

import SwiftUI

struct IntroOverlayView: View {
    @Binding var showIntro: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissOverlay()
                }
            
            VStack(spacing: 24) {
                Text("Welcome to your Progress Page 🌿")
                    .font(.system(.title2, design: .serif))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Here you'll see how your check-ins and moods change over time. It's not about being perfect — it's about understanding yourself better.")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                
                Button(action: dismissOverlay) {
                    Text("Got it")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color(hex: "#B5A7E0"))
                        )
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
            )
            .padding(.horizontal, 32)
        }
        .transition(.opacity)
    }
    
    private func dismissOverlay() {
        withAnimation(.easeInOut(duration: 0.6)) {
            showIntro = false
        }
        UserDefaults.standard.set(true, forKey: "trackingIntroShown")
        HapticFeedback.soft()
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var showIntro = true

        var body: some View {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#6E63A4"), Color(hex: "#B5A7E0")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if showIntro {
                    IntroOverlayView(showIntro: $showIntro)
                }
            }
        }
    }

    return PreviewWrapper()
}
