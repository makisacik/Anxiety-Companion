//
//  CalmJourneyView.swift
//  AnxietyTest&Companion
//


import SwiftUI
import CoreData

struct CalmJourneyView: View {
    @StateObject private var dataStore = CalmJourneyDataStore.shared
    @AppStorage("isPremiumUser") private var isPremiumUser = false

    @State private var completedLevels: [Int] = []
    @State private var dismissedPromoCards: Set<Int> = []
    @State private var showPaywall = false
    @State private var selectedLevel: CalmLevel?
    @State private var showReportGeneration = false

    private let levelSpacing: CGFloat = 50

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#6E63A4"), Color(hex: "#B5A7E0")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        header
                            .padding(.horizontal, 24)
                            .padding(.top, 40)
                            .padding(.bottom, 30)

                        VStack(spacing: levelSpacing) {
                            ForEach(Array(dataStore.levels.enumerated()), id: \.element.id) { index, level in
                                VStack(spacing: levelSpacing) {
                                    ZigZagLevelRow(
                                        level: level,
                                        index: index,
                                        isCompleted: completedLevels.contains(level.id),
                                        isPremiumUser: isPremiumUser,
                                        isMilestoneLevel: level.id == 5 || level.id == 10
                                    ) {
                                        handleTap(level)
                                    }

                                    // milestone report cards
                                    if (level.id == 5 || level.id == 10),
                                       !dismissedPromoCards.contains(level.id) {
                                        CalmReportPromoCard(
                                            level: level,
                                            isPremiumUser: isPremiumUser,
                                            isCompleted: checkCompletion(for: level.id),
                                            onViewReport: {
                                                if isPremiumUser {
                                                    showReportGeneration = true
                                                } else {
                                                    showPaywall = true
                                                }
                                            },
                                            onShowPaywall: { showPaywall = true },
                                            onClose: { dismissedPromoCards.insert(level.id) }
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 60)
                    }
                }

                // Hidden navigation link for level view
                NavigationLink(
                    destination: Group {
                        if let level = selectedLevel {
                            CalmLevelSessionView(
                                level: level,
                                isPremiumUser: isPremiumUser,
                                onLevelCompleted: { id in
                                    if !completedLevels.contains(id) {
                                        completedLevels.append(id)
                                        saveCompletedLevels()
                                    }
                                },
                                onViewReport: { showReportGeneration = true },
                                onShowPaywall: { showPaywall = true }
                            )
                        }
                    },
                    isActive: Binding(
                        get: { selectedLevel != nil },
                        set: { if !$0 { selectedLevel = nil } }
                    )
                ) { EmptyView() }

            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showReportGeneration) {
                CalmReportGenerationView() // self-contained
            }
            .onAppear(perform: loadCompletedLevels)
        }
    }

    // MARK: - Header
    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Calm Journey 🌿")
                .font(.largeTitle.bold())
                .foregroundColor(.white)

            Text("Structured exercises to build lasting calm, based on proven therapy techniques.")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
        }
        .multilineTextAlignment(.leading)
    }

    // MARK: - Helpers
    private func handleTap(_ level: CalmLevel) {
        HapticFeedback.light()
        if level.isLocked && !isPremiumUser {
            showPaywall = true
        } else {
            selectedLevel = level
        }
    }

    private func checkCompletion(for id: Int) -> Bool {
        if id == 5 { return (1...5).allSatisfy { completedLevels.contains($0) } }
        if id == 10 { return (1...10).allSatisfy { completedLevels.contains($0) } }
        return false
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



// MARK: - ZigZag Level Row

struct ZigZagLevelRow: View {
    let level: CalmLevel
    let index: Int
    let isCompleted: Bool
    let isPremiumUser: Bool
    let isMilestoneLevel: Bool
    let action: () -> Void

    private var isLeft: Bool { index % 2 == 0 }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if isLeft {
                node
                levelInfo
            } else {
                levelInfo
                node
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isCompleted)
    }

    private var node: some View {
        CalmJourneyNodeView(
            level: level,
            state: nodeState(),
            index: level.id
        )
        .onTapGesture(perform: action)
    }

    private var levelInfo: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(level.title)
                    .font(.system(.title3, design: .serif))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                if !level.free && !isPremiumUser {
                    Image(systemName: "lock.fill")
                        .font(.system(.caption, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            Text(level.summary)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .onTapGesture(perform: action)
    }

    private func nodeState() -> NodeState {
        if isCompleted { return .completed }
        return (level.free || isPremiumUser) ? .active : .locked
    }
}

#Preview {
    CalmJourneyView()
}
