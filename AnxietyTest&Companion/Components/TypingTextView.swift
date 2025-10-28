//
//  TypingTextView.swift
//  AnxietyTest&Companion
//
//  Created by Mehmet Ali Kısacık on 26.10.2025.
//

import SwiftUI
import Combine

struct TypingTextView: View {
    let text: String
    let onComplete: () -> Void
    
    @State private var displayedText = ""
    @State private var timer: Timer?
    @State private var currentIndex = 0
    @State private var isComplete = false
    
    // Accessibility
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(displayedText)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.themeText)
                .multilineTextAlignment(.leading)
                .accessibilityLabel(isComplete ? text : displayedText)
                .accessibilityAddTraits(isComplete ? [] : .updatesFrequently)
        }
        .onAppear {
            startTyping()
        }
        .onDisappear {
            stopTyping()
        }
    }
    
    private func startTyping() {
        guard !text.isEmpty else {
            onComplete()
            return
        }
        
        if reduceMotion {
            // For accessibility, show text immediately
            displayedText = text
            isComplete = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onComplete()
            }
            return
        }
        
        currentIndex = 0
        displayedText = ""
        isComplete = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            if currentIndex < text.count {
                let index = text.index(text.startIndex, offsetBy: currentIndex)
                displayedText = String(text[..<index])
                currentIndex += 1
            } else {
                // Typing complete
                displayedText = text
                isComplete = true
                stopTyping()
                HapticFeedback.soft()
                onComplete()
            }
        }
    }
    
    private func stopTyping() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    VStack(spacing: 20) {
        TypingTextView(text: "I'm here to help you understand how you've been feeling.") {
            print("Typing complete!")
        }
        
        TypingTextView(text: "This isn't a therapy app. It's a gentle space for self-check and reflection.") {
            print("Second message complete!")
        }
    }
    .padding()
    .background(Color.themeBackground)
}
