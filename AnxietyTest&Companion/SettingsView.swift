//
//  SettingsView.swift
//  AnxietyTest&Companion
//
//  Created by Mehmet Ali Kısacık on 26.10.2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("isPremiumUser") private var isPremiumUser = false
    @State private var actualNotificationStatus: Bool = false
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(hex: "#6E63A4"), Color(hex: "#B5A7E0")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(.all)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Settings")
                                .font(.system(.largeTitle, design: .serif))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Customize your experience")
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                        
                        // Reminders Section
                        VStack(spacing: 20) {
                            // Section Header
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(Color(hex: "#B5A7E0"))
                                    .font(.system(size: 20))
                                
                                Text("Reminders")
                                    .font(.system(.title2, design: .serif))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            
                            // Reminder Toggle Card
                            VStack(spacing: 16) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Gentle Check-ins")
                                            .font(.system(.headline, design: .rounded))
                                            .foregroundColor(.white)
                                        
                                        Text("Get gentle reminders to check in on your wellbeing every few days")
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundColor(.white.opacity(0.7))
                                            .multilineTextAlignment(.leading)
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $notificationsEnabled)
                                        .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#B5A7E0")))
                                        .onChange(of: notificationsEnabled) { newValue in
                                            handleToggleChange(newValue)
                                        }
                                }
                                
                                // Status indicator
                                if !isLoading {
                                    HStack {
                                        Image(systemName: actualNotificationStatus ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                            .foregroundColor(actualNotificationStatus ? .green : .orange)
                                        
                                        Text(statusText)
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundColor(.white.opacity(0.8))
                                        
                                        Spacer()
                                    }
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Development Settings
                        VStack(spacing: 20) {
                            HStack {
                                Image(systemName: "gearshape.fill")
                                    .foregroundColor(Color(hex: "#B5A7E0"))
                                    .font(.system(size: 20))
                                
                                Text("Development")
                                    .font(.system(.title2, design: .serif))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            
                            VStack(spacing: 12) {
                                // Premium Toggle for Testing
                                VStack(spacing: 16) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Premium Access")
                                                .font(.system(.headline, design: .rounded))
                                                .foregroundColor(.white)

                                            Text("Unlock all Calm Journey levels for testing")
                                                .font(.system(.caption, design: .rounded))
                                                .foregroundColor(.white.opacity(0.7))
                                                .multilineTextAlignment(.leading)
                                        }

                                        Spacer()

                                        Toggle("", isOn: $isPremiumUser)
                                            .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#B5A7E0")))
                                    }
                                }
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                )

                                SettingsRow(
                                    icon: "clock.fill",
                                    title: "Reminder Frequency",
                                    subtitle: "Customize how often you get reminders",
                                    isEnabled: false
                                )
                                
                                SettingsRow(
                                    icon: "message.fill",
                                    title: "Message Customization",
                                    subtitle: "Personalize your reminder messages",
                                    isEnabled: false
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 60)
                    }
                }
            }
        }
        .onAppear {
            checkNotificationStatus()
        }
    }
    
    private var statusText: String {
        if notificationsEnabled && actualNotificationStatus {
            return "Reminders are active and working"
        } else if notificationsEnabled && !actualNotificationStatus {
            return "Reminders are off — enable them in iOS Settings 🌿"
        } else {
            return "Reminders are disabled"
        }
    }
    
    private func checkNotificationStatus() {
        isLoading = true
        ReminderScheduler.shared.checkAuthorizationStatus { status in
            DispatchQueue.main.async {
                actualNotificationStatus = status
                isLoading = false
            }
        }
    }
    
    private func handleToggleChange(_ isEnabled: Bool) {
        HapticFeedback.light()
        
        if isEnabled {
            // Enable reminders
            ReminderScheduler.shared.requestAuthorization { granted in
                DispatchQueue.main.async {
                    if granted {
                        actualNotificationStatus = true
                        HapticFeedback.success()
                    } else {
                        notificationsEnabled = false
                        actualNotificationStatus = false
                        HapticFeedback.warning()
                    }
                }
            }
        } else {
            // Disable reminders
            ReminderScheduler.shared.cancelReminders()
            actualNotificationStatus = false
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let isEnabled: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(isEnabled ? Color(hex: "#B5A7E0") : Color.white.opacity(0.4))
                .font(.system(size: 18))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(isEnabled ? .white : .white.opacity(0.6))
                
                Text(subtitle)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            if !isEnabled {
                Text("Coming Soon")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                    )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

#Preview {
    SettingsView()
}
