//
//  AffirmationView.swift
//  AnxietyTest&Companion
//
//  Guided affirmation experience with typing animation and breathing prompts.
//

import SwiftUI

struct AffirmationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentAffirmationIndex = 0
    @State private var showSuccessMessage = false
    @State private var startTime = Date()
    @State private var isShowingAffirmation = false
    @State private var breathingTimer: Timer?
    @State private var breathingCount = 0
    @State private var isBreathingPhase = true
    
    private var affirmations: [String] {
        [
            String(localized: "affirmation_1"),
            String(localized: "affirmation_2"),
            String(localized: "affirmation_3"),
            String(localized: "affirmation_4"),
            String(localized: "affirmation_5"),
            String(localized: "affirmation_6"),
            String(localized: "affirmation_7"),
            String(localized: "affirmation_8"),
            String(localized: "affirmation_9"),
            String(localized: "affirmation_10")
        ]
    }
    
    private var currentAffirmation: String {
        affirmations[currentAffirmationIndex]
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#6E63A4"), Color(hex: "#B5A7E0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                HStack {
                    Text("🌸")
                        .font(.system(size: 40))
                    
                    Spacer()
                    
                    Button(String(localized: "affirmation_new")) {
                        nextAffirmation()
                    }
                    .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // Main content
                VStack(spacing: 24) {
                    Text(String(localized: "affirmation_title"))
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    if isBreathingPhase {
                        // Breathing phase
                        VStack(spacing: 20) {
                            Text(String(localized: "affirmation_breath"))
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text(String(localized: "affirmation_breath_cycle"))
                                .font(.body)
                                .foregroundColor(.white.opacity(0.7))
                            
                            // Breathing circle
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 3)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Circle()
                                        .fill(Color.white.opacity(0.1))
                                        .frame(width: 80, height: 80)
                                        .scaleEffect(breathingCount % 2 == 0 ? 1.2 : 0.8)
                                        .animation(.easeInOut(duration: 2), value: breathingCount)
                                )
                            
                            Text(String.localizedStringWithFormat(String(localized: "affirmation_breath_count"), breathingCount + 1))
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.vertical, 40)
                    } else {
                        // Affirmation phase
                        VStack(spacing: 20) {
                            Text(String(localized: "affirmation_repeat"))
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.8))
                            
                            TypingTextView(text: currentAffirmation) {
                                // Typing complete
                                HapticManager.shared.soft()
                            }
                            .font(.title2)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            
                            Text(String(localized: "affirmation_say"))
                                .font(.body)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.vertical, 20)
                    }
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 16) {
                    if isBreathingPhase {
                        Button(String(localized: "affirmation_start")) {
                            startAffirmationPhase()
                        }
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(Color(hex: "#B5A7E0"))
                        .cornerRadius(25)
                        .foregroundColor(.white)
                    } else {
                        HStack(spacing: 20) {
                            Button(String(localized: "affirmation_complete_button")) {
                                completeAffirmation()
                            }
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color(hex: "#B5A7E0"))
                            .cornerRadius(25)
                            .foregroundColor(.white)
                            
                            Button(String(localized: "affirmation_next")) {
                                nextAffirmation()
                            }
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(25)
                            .foregroundColor(.white)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            
            // Success overlay
            if showSuccessMessage {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismiss()
                    }
                
                VStack(spacing: 20) {
                    Text("💫")
                        .font(.system(size: 60))
                    
                    Text(String(localized: "affirmation_done_title"))
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    Text(String(localized: "affirmation_done_message"))
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(40)
                .background(Color(hex: "#6E63A4").opacity(0.95))
                .cornerRadius(20)
                .padding(.horizontal, 24)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .medium))
                }
            }
        }
        .onAppear {
            startTime = Date()
            startBreathingTimer()
        }
        .onDisappear {
            breathingTimer?.invalidate()
        }
    }
    
    private func startBreathingTimer() {
        breathingTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            breathingCount += 1
            HapticManager.shared.light()
            
            if breathingCount >= 3 {
                breathingTimer?.invalidate()
            }
        }
    }
    
    private func startAffirmationPhase() {
        isBreathingPhase = false
        HapticManager.shared.soft()
    }
    
    private func nextAffirmation() {
        currentAffirmationIndex = (currentAffirmationIndex + 1) % affirmations.count
        isBreathingPhase = true
        breathingCount = 0
        startBreathingTimer()
        HapticManager.shared.light()
    }
    
    private func completeAffirmation() {
        let duration = Int(Date().timeIntervalSince(startTime))
        
        // Save activity completion
        DataManager.shared.saveActivityCompletion(
            activityTitle: "Affirmation",
            duration: duration
        )
        
        HapticManager.shared.success()
        
        withAnimation(.easeInOut(duration: 0.5)) {
            showSuccessMessage = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        AffirmationView()
    }
}
