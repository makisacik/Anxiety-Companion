//
//  ReflectionView.swift
//  AnxietyTest&Companion
//
//  Short daily reflection with rotating prompt, save animation, and yesterday preview.
//

import SwiftUI

struct ReflectionView: View {
    var onSaved: (Date) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var text: String = ""
    @State private var showAffirmation = false
    @State private var currentPrompt: String = ""
    @State private var yesterdayPreview: String = ""

    // Prompt rotation persistence (deterministic: advances one per day, wraps around)
    @AppStorage("reflectionPromptIndex") private var promptIndex: Int = 0
    // Base date to compute day offset from (start from first prompt on first launch)
    @AppStorage("reflectionPromptBaseDate") private var promptBaseDateTimestamp: Double = 0

private let prompts = [
    "What tiny victory can you appreciate right now?",    
    "When did you feel most like yourself today?",
    "What moment made you feel safe or grounded today?",
    "What’s one thing that brought you a quiet smile?",
    "If your mind could rest on one thought tonight, what would it be?",
    "What helped you breathe easier today?",
    "What felt a little lighter than yesterday?",
    "What kindness — big or small — did you show yourself today?",
    "Was there a moment you handled something better than before?",
    "Who or what helped you feel supported today?",
    "What’s something you’re learning to let go of?",
    "When did you feel calm, even for a short moment?",
    "What do you wish to thank yourself for today?",
    "What made today feel a little more manageable?",
    "What’s one thing you want to carry into tomorrow?",
    "What thought or worry lost a bit of its power today?",
    "What helped you reconnect with the present moment?",
    "What do you appreciate about who you are becoming?",
    "What small act of care did you give your body or mind?",
    "What gave you a sense of peace, even briefly?"
]


    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.themeBackgroundPure, Color.themeBackground], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                .onTapGesture {
                    hideKeyboard()
                }

            VStack(spacing: 16) {
                // Header
                HStack(spacing: 12) {
                    Text("Reflect for a moment ✍️")
                        .font(.system(.title3, design: .serif)).fontWeight(.semibold)
                        .foregroundColor(.themeText)
                    Spacer()
                    Button(action: { randomizePrompt() }) {
                        Image(systemName: "shuffle")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.themeText.opacity(0.9))
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.themeBackgroundPure)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.themeDivider, lineWidth: 1))
                            )
                            .accessibilityLabel("Randomize prompt")
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // Prompt
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's prompt")
                        .font(.system(.caption, design: .rounded)).foregroundColor(.themeText.opacity(0.7))
                    Text(currentPrompt)
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.themeText)
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.themeBackgroundPure)
                                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.themeDivider, lineWidth: 1))
                        )
                }

                // Text field (short)
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.themeBackgroundPure)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.themeDivider, lineWidth: 1))
                        .frame(minHeight: 60)

                    if text.isEmpty {
                        Text("Write a few words…")
                            .foregroundColor(.themeText.opacity(0.4))
                            .padding(.horizontal, 14)
                    }

                    TextField("", text: $text, axis: .vertical)
                        .lineLimit(1...3)
                        .textInputAutocapitalization(.sentences)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .foregroundColor(.themeText)
                }

                // Yesterday preview
                if !yesterdayPreview.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your last reflection…")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.themeText.opacity(0.6))
                        Text(yesterdayPreview)
                            .font(.system(.footnote, design: .rounded))
                            .foregroundColor(.themeText.opacity(0.8))
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.themeBackgroundPure.opacity(0.7))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.themeDivider, lineWidth: 1))
                    )
                }

                // Save button
                Button(action: save) {
                    Text("Save Reflection")
                        .font(.system(.body, design: .rounded)).fontWeight(.medium)
                        .foregroundColor(.themeBackgroundPure)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.themeText)
                                .shadow(color: showAffirmation ? Color.themeText.opacity(0.3) : .clear, radius: showAffirmation ? 18 : 0)
                                .animation(.easeInOut(duration: 0.8), value: showAffirmation)
                        )
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()
            }
            .padding(.horizontal, 20)

            if showAffirmation {
                VStack(spacing: 8) {
                    Text("Saved ✨")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.themeText)
                    Text("You gave your mind a gentle pause.")
                        .font(.system(.footnote, design: .rounded))
                        .foregroundColor(.themeText.opacity(0.8))
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.themeBackgroundPure)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.themeDivider, lineWidth: 1))
                        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.themeText)
                        .font(.system(size: 18, weight: .medium))
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            updateDailyPrompt()
            yesterdayPreview = fetchYesterdayPreview()
            HapticFeedback.soft()
        }
    }

    private func save() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        DataManager.shared.saveJournalEntry(
            prompt: currentPrompt,
            content: trimmed,
            activityType: "reflection"
        )

        // Mark today complete
        onSaved(Date())

        withAnimation(.easeInOut(duration: 0.6)) { showAffirmation = true }
        HapticFeedback.success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            dismiss()
        }
    }

    // MARK: - Prompt Rotation (deterministic daily)
    private func updateDailyPrompt() {
        guard !prompts.isEmpty else { currentPrompt = ""; return }
        let now = Date()
        let startOfToday = now.startOfDay()

        // Initialize base date on first run to start with the first prompt
        if promptBaseDateTimestamp == 0 {
            promptBaseDateTimestamp = startOfToday.timeIntervalSince1970
            promptIndex = 0
        }

        let baseDate = Date(timeIntervalSince1970: promptBaseDateTimestamp)
        let days = Calendar.current.dateComponents([.day], from: baseDate.startOfDay(), to: startOfToday).day ?? 0
        let count = max(1, prompts.count)
        let idx = ((days % count) + count) % count // safe wrap for any sign
        promptIndex = idx
        currentPrompt = prompts[safe: promptIndex] ?? prompts.first ?? ""
    }

    private func fetchYesterdayPreview() -> String {
        // Fetch the most recent reflection entry
        let entries = DataManager.shared.fetchJournalEntries(by: "reflection")
        return entries.first?.content ?? ""
    }
    
    // MARK: - Randomize prompt action
    private func randomizePrompt() {
        guard !prompts.isEmpty else { return }
        let count = prompts.count
        var newIndex = Int.random(in: 0..<count)
        if count > 1 {
            // Try to avoid picking the same prompt
            var attempts = 0
            while newIndex == promptIndex && attempts < 5 {
                newIndex = Int.random(in: 0..<count)
                attempts += 1
            }
        }
        promptIndex = newIndex
        withAnimation(.easeInOut(duration: 0.25)) {
            currentPrompt = prompts[safe: newIndex] ?? currentPrompt
        }
        HapticFeedback.light()
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
