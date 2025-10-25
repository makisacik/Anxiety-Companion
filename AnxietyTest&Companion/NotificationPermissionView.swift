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
    
    let onPermissionGranted: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "#6E63A4"), Color(hex: "#B5A7E0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Main content card
                VStack(spacing: 24) {
                    // Companion at the top
                    CompanionFaceView(expression: .happy)
                        .scaleEffect(isVisible ? 1.2 : 0.8)
                        .opacity(isVisible ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.6).delay(0.2), value: isVisible)
                    
                    // Title
                    Text("🌿 Stay mindful of your calm.")
                        .font(.system(.title2, design: .serif))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    // Body text
                    Text("Would you like gentle reminders to check in on how you're feeling? You'll only get them every few days — no spam, just care.")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
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
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color(hex: "#B5A7E0"))
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
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .accessibilityLabel("Skip reminders for now")
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
                .scaleEffect(isVisible ? 1.0 : 0.8)
                .opacity(isVisible ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.6), value: isVisible)
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation {
                isVisible = true
            }
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
