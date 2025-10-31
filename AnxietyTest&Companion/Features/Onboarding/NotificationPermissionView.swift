//
//  NotificationPermissionView.swift
//  AnxietyTest&Companion
//
//  Created by Mehmet Ali Kısacık on 26.10.2025.
//

import SwiftUI

struct NotificationPermissionView: View {
    @Binding var isVisible: Bool
    let onPermissionGranted: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(isVisible ? 0.4 : 0)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.3), value: isVisible)
                .onTapGesture { dismissPopup() }

            // Popup card (slightly lower)
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                        Text(String(localized: "onboarding_notification_title"))
                        .font(.system(.title3, design: .serif))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.themeText)

                        Text(String(localized: "onboarding_notification_description"))
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.themeText.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal)

                    VStack(spacing: 12) {
                        // Primary: outlined "Yes"
                        Button(action: {
                            HapticFeedback.success()
                            handlePermissionRequest()
                        }) {
                                Text(String(localized: "onboarding_notification_allow_button"))
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(.themeText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color.themeDivider, lineWidth: 1)
                                )
                        }
                        .buttonStyle(ScaleButtonStyle())

                        // Secondary: plain "Not now"
                        Button(action: {
                            HapticFeedback.soft()
                            dismissPopup()
                        }) {
                                Text(String(localized: "onboarding_notification_skip_button"))
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(.themeText.opacity(0.8))
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                        }
                        .buttonStyle(ScaleButtonStyle())
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
            }
            .padding(.horizontal, 40)
            .offset(y: 60)
            .scaleEffect(isVisible ? 1.0 : 0.8)
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isVisible)
        }
    }

    private func handlePermissionRequest() {
        UserDefaults.standard.set(true, forKey: "reminderPromptShown")
        UserDefaults.standard.set(true, forKey: "hasShownNotificationPrompt")

        ReminderScheduler.shared.requestAuthorization { granted in
            DispatchQueue.main.async {
                if granted {
                    onPermissionGranted()
                }
                dismissPopup()
            }
        }
    }

    private func dismissPopup() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}
