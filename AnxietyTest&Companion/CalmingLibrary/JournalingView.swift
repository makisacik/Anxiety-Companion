//
//  JournalingView.swift
//  AnxietyTest&Companion
//
//  Guided journaling with prompts and text editor.
//

import SwiftUI

struct JournalingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var journalText = ""
    @State private var showSuccessMessage = false
    @State private var startTime = Date()
    @State private var showHistory = false
    
    private var prompts: [String] {
        [
            String(localized: "journaling_prompt_1"),
            String(localized: "journaling_prompt_2"),
            String(localized: "journaling_prompt_3"),
            String(localized: "journaling_prompt_4"),
            String(localized: "journaling_prompt_5"),
            String(localized: "journaling_prompt_6"),
            String(localized: "journaling_prompt_7"),
            String(localized: "journaling_prompt_8"),
            String(localized: "journaling_prompt_9"),
            String(localized: "journaling_prompt_10")
        ]
    }
    
    @State private var currentPrompt: String = ""
    
    init() {
        let prompts = [
            String(localized: "journaling_prompt_1"),
            String(localized: "journaling_prompt_2"),
            String(localized: "journaling_prompt_3"),
            String(localized: "journaling_prompt_4"),
            String(localized: "journaling_prompt_5"),
            String(localized: "journaling_prompt_6"),
            String(localized: "journaling_prompt_7"),
            String(localized: "journaling_prompt_8"),
            String(localized: "journaling_prompt_9"),
            String(localized: "journaling_prompt_10")
        ]
        _currentPrompt = State(initialValue: prompts.randomElement() ?? prompts[0])
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#6E63A4"), Color(hex: "#B5A7E0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(String(localized: "journaling_history")) {
                        showHistory = true
                    }
                    .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("🖊️")
                        .font(.system(size: 30))
                    
                    Spacer()
                    
                    Button(String(localized: "journaling_new_prompt")) {
                        currentPrompt = prompts.randomElement() ?? prompts[0]
                        HapticManager.shared.light()
                    }
                    .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // Prompt
                VStack(spacing: 16) {
                    Text(String(localized: "journaling_prompt_label"))
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(currentPrompt)
                        .font(.title2)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 24)
                
                // Text editor
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(String(localized: "journaling_your_thoughts"))
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                        
                        Text(String.localizedStringWithFormat(String(localized: "journaling_characters"), journalText.count))
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
                            .frame(minHeight: 200)
                        
                        if journalText.isEmpty {
                            Text(String(localized: "journaling_placeholder"))
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                        }
                        
                        TextEditor(text: $journalText)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Save button
                Button(String(localized: "journaling_save")) {
                    saveJournalEntry()
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 12)
                .background(journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.white.opacity(0.3) : Color(hex: "#B5A7E0"))
                .cornerRadius(25)
                .foregroundColor(.white)
                .disabled(journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
                    Text("📝")
                        .font(.system(size: 60))
                    
                    Text(String(localized: "journaling_saved_title"))
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    Text(String(localized: "journaling_saved_message"))
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
        .sheet(isPresented: $showHistory) {
            JournalHistoryView()
        }
        .onAppear {
            startTime = Date()
        }
    }
    
    private func saveJournalEntry() {
        let duration = Int(Date().timeIntervalSince(startTime))
        let trimmedText = journalText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedText.isEmpty else { return }
        
        // Save to CoreData
        DataManager.shared.saveJournalEntry(
            prompt: currentPrompt,
            content: trimmedText,
            activityType: "journaling"
        )
        
        // Save activity completion
        DataManager.shared.saveActivityCompletion(
            activityTitle: "Journaling",
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
        JournalingView()
    }
}
