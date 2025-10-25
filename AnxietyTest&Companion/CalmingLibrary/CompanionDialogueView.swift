//
//  CompanionDialogueView.swift
//  AnxietyTest&Companion
//
//  Displays the companion's calm text with typing animation.
//

import SwiftUI

struct CompanionDialogueView: View {
    let text: String
    @State private var displayedText = ""
    @State private var charIndex = 0
    @State private var typingTimer: Timer?

    var body: some View {
        Text(displayedText)
            .font(.title3.weight(.medium))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .onAppear {
                startTypingAnimation()
            }
            .onChange(of: text) {
                restartTypingAnimation()
            }
            .onDisappear {
                typingTimer?.invalidate()
            }
            .animation(.easeInOut, value: displayedText)
    }

    // MARK: - Typing Animation Logic
    private func startTypingAnimation() {
        displayedText = ""
        charIndex = 0
        typingTimer?.invalidate()

        typingTimer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { timer in
            if charIndex < text.count {
                let index = text.index(text.startIndex, offsetBy: charIndex)
                displayedText += String(text[index])
                charIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }

    private func restartTypingAnimation() {
        typingTimer?.invalidate()
        startTypingAnimation()
    }
}
