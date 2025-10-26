//
//  CompanionChatBubbleView.swift
//  AnxietyTest&Companion
//
//  Companion with chat bubble for Duolingo-style instruction presentation.
//

import SwiftUI

struct CompanionChatBubbleView: View {
    let message: String
    let showSpeakerIcon: Bool
    let companionExpression: CompanionFaceView.Expression
    
    @State private var isVisible = false
    
    init(message: String, showSpeakerIcon: Bool = false, companionExpression: CompanionFaceView.Expression = .neutral) {
        self.message = message
        self.showSpeakerIcon = showSpeakerIcon
        self.companionExpression = companionExpression
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Companion on the left
            CompanionFaceView(expression: companionExpression)
                .scaleEffect(0.8)
            
            // Chat bubble on the right
            VStack(alignment: .leading, spacing: 12) {
                // Chat bubble
                HStack(alignment: .top, spacing: 12) {
                    if showSpeakerIcon {
                        Button(action: {
                            // TODO: Add text-to-speech functionality
                            HapticFeedback.light()
                        }) {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Text(message)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            
            Spacer()
        }
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : -20)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).delay(0.2)) {
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
        
        VStack(spacing: 32) {
            CompanionChatBubbleView(
                message: "When you feel anxious, your body activates the fight-flight-freeze response.",
                showSpeakerIcon: false,
                companionExpression: .neutral
            )
            
            CompanionChatBubbleView(
                message: "Name 5 things you can see.",
                showSpeakerIcon: true,
                companionExpression: .happy
            )
            
            CompanionChatBubbleView(
                message: "Inhale for 4 seconds.",
                showSpeakerIcon: false,
                companionExpression: .calm
            )
        }
        .padding()
    }
}
