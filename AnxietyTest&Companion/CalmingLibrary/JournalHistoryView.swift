//
//  JournalHistoryView.swift
//  AnxietyTest&Companion
//
//  View past journal entries with expandable content.
//

import SwiftUI

struct JournalHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var journalEntries: [JournalEntry] = []
    @State private var expandedEntry: UUID?
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#6E63A4"), Color(hex: "#B5A7E0")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("📝")
                            .font(.system(size: 30))
                        
                        Text(String(localized: "journal_history_title"))
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(String(localized: "journal_history_done")) {
                            dismiss()
                        }
                        .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    if journalEntries.isEmpty {
                        // Empty state
                        VStack(spacing: 20) {
                            Spacer()
                            
                            Text("📖")
                                .font(.system(size: 80))
                            
                            Text(String(localized: "journal_history_empty_title"))
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            
                            Text(String(localized: "journal_history_empty_message"))
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
                            Spacer()
                        }
                    } else {
                        // Entries list
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(journalEntries, id: \.id) { entry in
                                    JournalEntryCard(
                                        entry: entry,
                                        isExpanded: expandedEntry == entry.id,
                                        onToggle: {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                if expandedEntry == entry.id {
                                                    expandedEntry = nil
                                                } else {
                                                    expandedEntry = entry.id
                                                }
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
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
            loadJournalEntries()
        }
    }
    
    private func loadJournalEntries() {
        journalEntries = DataManager.shared.fetchJournalEntries()
    }
}

struct JournalEntryCard: View {
    let entry: JournalEntry
    let isExpanded: Bool
    let onToggle: () -> Void
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: entry.date ?? Date())
    }
    
    private var contentPreview: String {
        let content = entry.content ?? ""
        if content.count > 100 {
            return String(content.prefix(100)) + "..."
        }
        return content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formattedDate)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(entry.prompt ?? String(localized: "journal_history_entry_default"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Button(action: onToggle) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 16, weight: .medium))
                }
            }
            
            // Content
            Text(isExpanded ? (entry.content ?? "") : contentPreview)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(isExpanded ? nil : 3)
                .animation(.easeInOut(duration: 0.3), value: isExpanded)
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .onTapGesture {
            onToggle()
        }
    }
}

#Preview {
    JournalHistoryView()
}
