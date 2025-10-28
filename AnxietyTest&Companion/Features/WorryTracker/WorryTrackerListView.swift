//
//  WorryTrackerListView.swift
//  AnxietyTest&Companion
//
//  Created by GitHub Copilot on 29.10.2025.
//

import SwiftUI
import CoreData

struct WorryTrackerListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: WorryTrackerViewModel
    @State private var showingAddWorry = false
    @State private var showingWorryIntro = false
    @State private var hasCheckedIntro = false
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: WorryTrackerViewModel(context: context))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "bubble.left.and.exclamationmark.bubble.right.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.themeText.opacity(0.8))
                        .padding(.top, 20)
                    
                    Text("Worry Tracker")
                        .font(.system(.largeTitle, design: .serif))
                        .fontWeight(.bold)
                        .foregroundColor(.themeText)
                    
                    Text("Notice how worries change over time")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.themeText.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.bottom, 10)
                
                // Ready to Reflect Section
                if !viewModel.ready.isEmpty {
                    sectionView(title: "🌿 Ready to Reflect", items: viewModel.ready, isReady: true)
                }
                
                // Pending Worries Section
                if !viewModel.pending.isEmpty {
                    sectionView(title: "⏳ Pending Worries", items: viewModel.pending, isPending: true)
                }
                
                // Completed Section
                if !viewModel.completed.isEmpty {
                    sectionView(title: "✅ Completed", items: viewModel.completed, isCompleted: true)
                }
                
                // Empty state
                if viewModel.pending.isEmpty && viewModel.ready.isEmpty && viewModel.completed.isEmpty {
                    emptyStateView
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .background(
            ZStack {
                Color.themeBackground
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    Image("tree-footer")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .opacity(0.2)
                }
                .ignoresSafeArea()
            }
        )
        .overlay(alignment: .bottom) {
            addButton
        }
        .sheet(isPresented: $showingAddWorry) {
            NavigationStack {
                WorryLogEntryView(viewModel: viewModel)
            }
        }
        .fullScreenCover(isPresented: $showingWorryIntro) {
            WorryIntroView(isPresented: $showingWorryIntro)
        }
        .onAppear {
            viewModel.refresh()
            // Only check intro once per view lifecycle
            if !hasCheckedIntro {
                hasCheckedIntro = true
                let hasSeenIntro = UserDefaults.standard.bool(forKey: "hasSeenWorryIntro")
                if !hasSeenIntro {
                    showingWorryIntro = true
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Section View
    
    @ViewBuilder
    private func sectionView(title: String, items: [WorryLog], isPending: Bool = false, isReady: Bool = false, isCompleted: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(.headline, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(.themeText)
                .padding(.horizontal, 4)
            
            ForEach(items, id: \.id) { worry in
                if isReady {
                    NavigationLink(destination: WorryReflectionView(worry: worry, viewModel: viewModel)) {
                        worryCard(worry: worry, isPending: isPending, isReady: isReady, isCompleted: isCompleted)
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    worryCard(worry: worry, isPending: isPending, isReady: isReady, isCompleted: isCompleted)
                }
            }
        }
    }
    
    // MARK: - Worry Card
    
    private func worryCard(worry: WorryLog, isPending: Bool, isReady: Bool, isCompleted: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with date and status
            HStack {
                Text(worry.dateCreated?.formatted(date: .abbreviated, time: .shortened) ?? "")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.themeText.opacity(0.6))
                
                Spacer()
                
                if isCompleted {
                    Text(worry.wasBetter ? "🌞" : "☁️")
                        .font(.title3)
                }
                
                if isPending, let reminderDate = worry.reminderDate {
                    Text(viewModel.timeLeftString(for: reminderDate))
                        .font(.system(.caption2, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.themeText.opacity(0.7))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.themeDivider.opacity(0.3))
                        )
                }
            }
            
            // Worry text
            Text(worry.worryText ?? "")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.themeText)
                .lineLimit(3)
            
            // Control thought if exists
            if let control = worry.controlThought, !control.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "hand.point.right.fill")
                        .font(.caption2)
                        .foregroundColor(.green.opacity(0.7))
                    
                    Text(control)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.themeText.opacity(0.7))
                        .italic()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green.opacity(0.1))
                )
            }
            
            // Intensity indicator
            HStack(spacing: 4) {
                ForEach(0..<Int(worry.intensity), id: \.self) { _ in
                    Circle()
                        .fill(intensityColor(for: Int(worry.intensity)))
                        .frame(width: 6, height: 6)
                }
                
                Text("\(worry.intensity)/10")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(.themeText.opacity(0.6))
            }
            
            // Ready to reflect indicator
            if isReady {
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.green)
                    Text("Tap to reflect")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.themeCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isReady ? Color.green.opacity(0.5) : Color.themeDivider, lineWidth: isReady ? 2 : 1)
                )
        )
        .shadow(color: isReady ? Color.green.opacity(0.1) : Color.clear, radius: 8)
        .contextMenu {
            Button(role: .destructive) {
                viewModel.deleteWorry(worry)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 60))
                .foregroundColor(.themeText.opacity(0.3))
                .padding(.top, 60)
            
            Text("No worries yet")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(.themeText)
            
            Text("When you log a worry, you can reflect on it later and see how things actually turned out")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.themeText.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 40)
    }
    
    // MARK: - Add Button
    
    private var addButton: some View {
        Button {
            HapticFeedback.light()
            showingAddWorry = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                Text("Log a Worry")
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
            }
            .foregroundColor(.themeBackgroundPure)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(Color.themeText)
            )
            .shadow(color: Color.themeText.opacity(0.3), radius: 10, y: 4)
        }
        .padding(.bottom, 30)
    }
    
    // MARK: - Helpers
    
    private func intensityColor(for intensity: Int) -> Color {
        switch intensity {
        case 0...3:
            return .green
        case 4...6:
            return .yellow
        case 7...8:
            return .orange
        default:
            return .red
        }
    }
}
