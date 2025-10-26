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
    
    private let prompts = [
        "What thought has been looping in your mind?",
        "What would you tell a friend feeling this way?",
        "What's one thing you can let go of today?",
        "Describe how your body feels right now",
        "What do you need most in this moment?",
        "What's been weighing on your heart lately?",
        "What small win can you celebrate today?",
        "What would you do if you weren't afraid?",
        "What brings you comfort when you're overwhelmed?",
        "What's one thing you're grateful for right now?"
    ]
    
    @State private var currentPrompt: String
    
    init() {
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
                    Button("History") {
                        showHistory = true
                    }
                    .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("🖊️")
                        .font(.system(size: 30))
                    
                    Spacer()
                    
                    Button("New Prompt") {
                        currentPrompt = prompts.randomElement() ?? prompts[0]
                        HapticManager.shared.light()
                    }
                    .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // Prompt
                VStack(spacing: 16) {
                    Text("Journal Prompt")
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
                        Text("Your thoughts")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                        
                        Text("\(journalText.count) characters")
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
                            Text("Start writing your thoughts here...")
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
                Button("Save Entry") {
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
                    
                    Text("Entry Saved!")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    Text("Your thoughts have been saved. Writing can be a powerful way to process emotions.")
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
