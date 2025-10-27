//
//  NotificationPermissionView.swift
//  AnxietyTest&Companion
//
//  Created by Mehmet Ali Kısacık on 26.10.2025.
//

import SwiftUI

struct NotificationPermissionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isVisible = false
    @State private var companionOffsetX: CGFloat = -400 // Start off-screen to the left
    @State private var companionRotation: Double = 0 // Track rotation for continuous rolling

    let onPermissionGranted: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            // Background
            Color.themeBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Companion outside the card, above it
                CompanionFaceView(expression: .happy)
                    .scaleEffect(isVisible ? 1.2 : 0.8)
                    .rotationEffect(.degrees(companionRotation)) // Continuous rolling rotation
                    .offset(x: companionOffsetX, y: -80)
                    .opacity(isVisible ? 1.0 : 0.0)

                // Main content card
                VStack(spacing: 24) {
                    // Title
                    Text("🌿 Stay mindful of your calm.")
                        .font(.system(.title2, design: .serif))
                        .fontWeight(.bold)
                        .foregroundColor(.themeText)
                        .multilineTextAlignment(.center)

                    // Body text
                    Text("Would you like gentle reminders to check in on how you're feeling? You'll only get them every few days — no spam, just care.")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.themeText.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    // Buttons
                    VStack(spacing: 16) {
                        // Primary button - Yes, remind me
                        Button(action: {
                            HapticFeedback.success()
                            handlePermissionRequest()
                        }) {
                            Text("Yes, remind me 🌤️")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(.themeText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.themeCard)
                                )
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .accessibilityLabel("Enable gentle reminders")

                        // Secondary button - Not now
                        Button(action: {
                            HapticFeedback.soft()
                            handleDismiss()
                        }) {
                            Text("Not now")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(.themeText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.themeDivider, lineWidth: 1)
                                )
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .accessibilityLabel("Skip reminders for now")
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.themeCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.themeDivider, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
                .padding(.top, 60) // Add top padding to make room for companion
                .scaleEffect(isVisible ? 1.0 : 0.8)
                .opacity(isVisible ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.6).delay(0.3), value: isVisible)

                Spacer()
            }
        }
        .onAppear {
            withAnimation {
                isVisible = true
            }

            // Start rolling animation - roll in from left and stop in center
            startRollingAnimation()
        }
    }

    private func startRollingAnimation() {
        // Roll in from left at a slower speed, stop at center (0)
        withAnimation(.easeOut(duration: 3.5)) {
            companionOffsetX = 0 // Stop in the center
            companionRotation = 360 // Full rotation
        }
    }

    private func handlePermissionRequest() {
        // Mark that we've shown the prompt
        UserDefaults.standard.set(true, forKey: "reminderPromptShown")
        UserDefaults.standard.set(true, forKey: "hasShownNotificationPrompt")

        // Request authorization
        ReminderScheduler.shared.requestAuthorization { granted in
            DispatchQueue.main.async {
                if granted {
                    onPermissionGranted()
                }
                dismiss()
            }
        }
    }

    private func handleDismiss() {
        // Mark that we've shown the prompt
        UserDefaults.standard.set(true, forKey: "reminderPromptShown")
        UserDefaults.standard.set(true, forKey: "hasShownNotificationPrompt")
        onDismiss()
        dismiss()
    }
}


#Preview {
    NotificationPermissionView(
        onPermissionGranted: {},
        onDismiss: {}
    )
}
