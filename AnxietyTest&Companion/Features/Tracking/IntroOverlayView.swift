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
                Text(String(localized: "tracking_intro_title"))
                    .font(.system(.title2, design: .serif))
                    .fontWeight(.semibold)
                    .foregroundColor(.themeText)
                    .multilineTextAlignment(.center)
                
                Text(String(localized: "tracking_intro_message"))
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.themeText.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                
                Button(action: dismissOverlay) {
                    Text(String(localized: "tracking_intro_got_it"))
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.themeText)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.themeCard)
                        )
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.themeCard)
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
