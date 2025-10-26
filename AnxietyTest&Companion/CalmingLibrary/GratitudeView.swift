//
//  GratitudeView.swift
//  AnxietyTest&Companion
//
//  Interactive gratitude reflection with guided prompts.
//

import SwiftUI

struct GratitudeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var gratitudeText = ""
    @State private var showSuccessMessage = false
    @State private var startTime = Date()
    @State private var currentPromptIndex = 0
    @State private var showGratitudeExercise = false

    private let prompts = [
        "What made you smile today?",
        "What's one thing you're grateful for right now?",
        "Who or what brought you comfort recently?",
        "What small moment brought you joy?",
        "What are you thankful for in this moment?"
    ]

    private var currentPrompt: String {
        prompts[currentPromptIndex]
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#6E63A4"), Color(hex: "#B5A7E0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if !showGratitudeExercise {
                introView
            } else {
                gratitudeExerciseView
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
        }
    }

    private var introView: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "heart.fill")
                .font(.system(size: 60))
                .foregroundColor(.white)
                .padding(30)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.2))
                )

            Text("Gratitude Reflection")
                .font(.system(.largeTitle, design: .serif))
                .fontWeight(.bold)
                .foregroundColor(.white)

            VStack(spacing: 16) {
                benefitRow(
                    icon: "brain.head.profile",
                    title: "Rewires Your Brain",
                    description: "Regular gratitude practice strengthens neural pathways linked to happiness and reduces activity in anxiety-related brain regions."
                )

                benefitRow(
                    icon: "sparkles",
                    title: "Shifts Perspective",
                    description: "Focusing on what you're grateful for helps you see the positive aspects of life, even during difficult times."
                )

                benefitRow(
                    icon: "bed.double.fill",
                    title: "Improves Sleep",
                    description: "Studies show that writing about things you're grateful for before bed can improve sleep quality and duration."
                )
            }
            .padding(.horizontal, 30)

            Spacer()

            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showGratitudeExercise = true
                }
                HapticManager.shared.soft()
            }) {
                HStack {
                    Image(systemName: "play.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Start Gratitude Practice")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                }
                .foregroundColor(Color(hex: "#6E63A4"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white)
                )
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
    }

    private func benefitRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color(hex: "#B5A7E0"))
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var gratitudeExerciseView: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Text("🌤️")
                    .font(.system(size: 40))

                Spacer()

                Button("New Prompt") {
                    currentPromptIndex = (currentPromptIndex + 1) % prompts.count
                    gratitudeText = ""
                    HapticManager.shared.light()
                }
                .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            // Main content
            VStack(spacing: 20) {
                Text("Gratitude Reflection")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)

                Text(currentPrompt)
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )

                // Text input
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Your gratitude")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))

                        Spacer()

                        Text("\(gratitudeText.count) characters")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }

                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .frame(minHeight: 120)

                        if gratitudeText.isEmpty {
                            Text("What are you grateful for?")
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                        }

                        TextEditor(text: $gratitudeText)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 24)
            }

            Spacer()

            // Save button
            Button("Save Gratitude") {
                saveGratitude()
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 12)
            .background(gratitudeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.white.opacity(0.3) : Color(hex: "#B5A7E0"))
            .cornerRadius(25)
            .foregroundColor(.white)
            .disabled(gratitudeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.bottom, 20)
        }
        .overlay(
            Group {
                if showSuccessMessage {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            dismiss()
                        }

                    VStack(spacing: 20) {
                        Text("✨")
                            .font(.system(size: 60))

                        Text("Gratitude Saved!")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)

                        Text("Focusing on gratitude can help shift your perspective and bring more positivity into your day.")
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
        )
        .onAppear {
            startTime = Date()
        }
    }

    private func saveGratitude() {
        let duration = Int(Date().timeIntervalSince(startTime))
        let trimmedText = gratitudeText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedText.isEmpty else { return }

        // Save to CoreData as journal entry
        DataManager.shared.saveJournalEntry(
            prompt: currentPrompt,
            content: trimmedText,
            activityType: "gratitude"
        )

        // Save activity completion
        DataManager.shared.saveActivityCompletion(
            activityTitle: "Gratitude",
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
        GratitudeView()
    }
}
