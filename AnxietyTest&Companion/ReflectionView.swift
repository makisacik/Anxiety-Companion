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

    // Prompt rotation persistence
    @AppStorage("reflectionPromptIndex") private var promptIndex: Int = 0
    @AppStorage("reflectionPromptChangeTimestamp") private var promptChangeTimestamp: Double = 0
    @AppStorage("reflectionPromptDurationDays") private var promptDurationDays: Int = 2 // 1–3

    private let prompts = [
        "What helped you stay calm today?",
        "What's something small you're grateful for?",
        "What anxious thought did you handle better today?",
        "What felt lighter than yesterday?",
        "Who or what brought you a moment of peace?"
    ]

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.themeBackgroundPure, Color.themeBackground], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("Reflect for a moment ✍️")
                        .font(.system(.title3, design: .serif)).fontWeight(.semibold)
                        .foregroundColor(.themeText)
                    Spacer()
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
                        Text("Yesterday you said…")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.themeText.opacity(0.6))
                        Text(yesterdayPreview)
                            .font(.system(.footnote, design: .rounded))
                            .foregroundColor(.themeText.opacity(0.8))
                            .lineLimit(2)
                    }
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
        .onAppear {
            rotatePromptIfNeeded()
            currentPrompt = prompts[safe: promptIndex] ?? prompts[0]
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

    // MARK: - Prompt Rotation
    private func rotatePromptIfNeeded() {
        let now = Date()
        if promptChangeTimestamp == 0 { setNewPrompt(at: now); return }
        let last = Date(timeIntervalSince1970: promptChangeTimestamp)
        let days = Calendar.current.dateComponents([.day], from: last.startOfDay(), to: now.startOfDay()).day ?? 0
        if days >= promptDurationDays { setNewPrompt(at: now) }
    }

    private func setNewPrompt(at date: Date) {
        promptIndex = Int.random(in: 0..<max(1, prompts.count))
        promptDurationDays = Int.random(in: 1...3)
        promptChangeTimestamp = date.timeIntervalSince1970
    }

    private func fetchYesterdayPreview() -> String {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())?.startOfDay() ?? Date().startOfDay()
        let today = Date().startOfDay()
        // Fetch reflections from yesterday only
        let entries = DataManager.shared.fetchJournalEntries(by: "reflection")
        if let entry = entries.first(where: { ($0.date ?? Date()).startOfDay() == yesterday }) {
            return entry.content ?? ""
        }
        // Or last reflection if yesterday empty
        return entries.first?.content ?? ""
    }
}
