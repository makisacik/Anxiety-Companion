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
    
    private let affirmations = [
        "I'm allowed to take things slow",
        "I'm doing the best I can",
        "My feelings are valid",
        "I deserve kindness and rest",
        "I am stronger than I think",
        "It's okay to not be okay",
        "I am worthy of love and care",
        "This feeling will pass",
        "I am safe in this moment",
        "I trust myself to handle whatever comes"
    ]
    
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
                    
                    Button("New Affirmation") {
                        nextAffirmation()
                    }
                    .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // Main content
                VStack(spacing: 24) {
                    Text("Affirmation")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    if isBreathingPhase {
                        // Breathing phase
                        VStack(spacing: 20) {
                            Text("Take a deep breath")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text("Breathe in... hold... breathe out")
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
                            
                            Text("\(breathingCount + 1) / 3")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.vertical, 40)
                    } else {
                        // Affirmation phase
                        VStack(spacing: 20) {
                            Text("Repeat this to yourself:")
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
                            
                            Text("Say it out loud or in your mind")
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
                        Button("Start Affirmation") {
                            startAffirmationPhase()
                        }
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(Color(hex: "#B5A7E0"))
                        .cornerRadius(25)
                        .foregroundColor(.white)
                    } else {
                        HStack(spacing: 20) {
                            Button("Complete") {
                                completeAffirmation()
                            }
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color(hex: "#B5A7E0"))
                            .cornerRadius(25)
                            .foregroundColor(.white)
                            
                            Button("Next") {
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
                    
                    Text("Affirmation Complete!")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    Text("You've taken a moment to speak kindness to yourself. Remember, you are worthy of compassion.")
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
