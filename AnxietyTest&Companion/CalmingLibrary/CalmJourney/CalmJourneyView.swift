//
//  CalmJourneyView.swift
//  AnxietyTest&Companion
//
//  Main level selection screen for Calm Journey with 5 progressive levels.
//

import SwiftUI

struct CalmJourneyView: View {
    @StateObject private var dataStore = CalmJourneyDataStore.shared
    @AppStorage("isPremiumUser") private var isPremiumUser = false
    @State private var completedLevels: [Int] = []
    @State private var showPaywall = false
    @State private var pendingLevel: CalmLevel?
    @State private var selectedLevel: CalmLevel?
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "#6E63A4"), Color(hex: "#B5A7E0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    headerSection
                    
                    // Levels
                    LazyVStack(spacing: 16) {
                        ForEach(dataStore.levels) { level in
                            CalmLevelCard(
                                level: level,
                                isPremiumUser: isPremiumUser,
                                isCompleted: completedLevels.contains(level.id),
                                onTap: {
                                    handleLevelTap(level)
                                }
                            )
                        }
                    }
                    .padding(.vertical, 20)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showPaywall, onDismiss: {
            // After paywall is dismissed, the user can try accessing the level again
            print("🚪 Paywall dismissed, pending level: \(pendingLevel?.title ?? "none")")
            pendingLevel = nil
        }) {
            PaywallView()
        }
        .background(
            NavigationLink(
                destination: selectedLevel.map { level in
                    CalmLevelSessionView(
                        level: level,
                        onLevelCompleted: { levelId in
                            if !completedLevels.contains(levelId) {
                                completedLevels.append(levelId)
                                saveCompletedLevels()
                            }
                        }
                    )
                },
                isActive: Binding(
                    get: { selectedLevel != nil },
                    set: { if !$0 { selectedLevel = nil } }
                )
            ) {
                EmptyView()
            }
        )
        .onAppear {
            loadCompletedLevels()
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Calm Journey 🌿")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
            
            Text("Structured exercises to build lasting calm, based on proven therapy techniques.")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
            
            // Premium status indicator
            if isPremiumUser {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(Color(hex: "#B5A7E0"))
                    Text("Premium Unlocked")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
            }
        }
        .padding(.top, 40)
    }
    
    private func handleLevelTap(_ level: CalmLevel) {
        HapticFeedback.light()
        print("🔓 Tapped level: \(level.title), isLocked: \(level.isLocked), isPremium: \(isPremiumUser)")
        
        // For testing: Allow all levels to open, but show paywall for locked levels
        if level.isLocked && !isPremiumUser {
            // Store the level to open after paywall
            pendingLevel = level
            print("🔒 Showing paywall for level: \(level.title)")
            showPaywall = true
        } else {
            print("✅ Opening level directly: \(level.title)")
            selectedLevel = level
        }
    }

    private func loadCompletedLevels() {
        if let data = UserDefaults.standard.data(forKey: "completedLevels"),
           let levels = try? JSONDecoder().decode([Int].self, from: data) {
            completedLevels = levels
        }
    }

    private func saveCompletedLevels() {
        if let data = try? JSONEncoder().encode(completedLevels) {
            UserDefaults.standard.set(data, forKey: "completedLevels")
        }
    }
}

struct CalmLevelCard: View {
    let level: CalmLevel
    let isPremiumUser: Bool
    let isCompleted: Bool
    let onTap: () -> Void

    private var isAccessible: Bool {
        return level.free || isPremiumUser
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Level number and icon
                VStack {
                    ZStack {
                        Circle()
                            .fill(isCompleted ? Color(hex: "#B5A7E0") : (isAccessible ? Color.white.opacity(0.2) : Color.white.opacity(0.1)))
                            .frame(width: 50, height: 50)
                            .shadow(radius: isCompleted ? 8 : 0)
                        
                        if isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(.title3, weight: .bold))
                                .foregroundColor(.white)
                        } else if isAccessible {
                            Text("\(level.id)")
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "lock.fill")
                                .font(.system(.title3, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(level.title)
                            .font(.system(.title3, design: .serif))
                            .fontWeight(.semibold)
                            .foregroundColor(isAccessible ? .white : .white.opacity(0.6))
                        
                        Spacer()
                        
                        if !isAccessible {
                            Image(systemName: "lock.fill")
                                .font(.system(.caption, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    
                    Text(level.summary)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(isAccessible ? .white.opacity(0.8) : .white.opacity(0.5))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Exercise count
                    HStack {
                        Image(systemName: "list.bullet")
                            .font(.system(.caption, weight: .medium))
                            .foregroundColor(isAccessible ? .white.opacity(0.7) : .white.opacity(0.4))
                        
                        Text("\(level.exercises.count) exercises")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(isAccessible ? .white.opacity(0.7) : .white.opacity(0.4))
                        
                        Spacer()
                        
                        if isAccessible {
                            Image(systemName: "chevron.right")
                                .font(.system(.caption, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(ScaleButtonStyle())
        // .disabled(!isAccessible) // Removed for testing - allows locked levels to be tapped
    }
}

#Preview {
    CalmJourneyView()
}
