//
//  CalmJourneyView.swift
//  AnxietyTest&Companion
//
//  Final clean version — header outside, spacing 50
//

import SwiftUI

struct CalmJourneyView: View {
    @StateObject private var dataStore = CalmJourneyDataStore.shared
    @AppStorage("isPremiumUser") private var isPremiumUser = false
    @State private var completedLevels: [Int] = []
    @State private var showPaywall = false
    @State private var pendingLevel: CalmLevel?
    @State private var selectedLevel: CalmLevel?

    private let levelSpacing: CGFloat = 50

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#E6E6FA"), Color(hex: "#FFE4E1")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header stays fixed at top
                headerSection
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    .padding(.bottom, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: levelSpacing) {
                        ForEach(Array(dataStore.levels.enumerated()), id: \.element.id) { index, level in
                            ZigZagLevelRow(
                                level: level,
                                index: index,
                                isCompleted: completedLevels.contains(level.id),
                                isPremiumUser: isPremiumUser
                            ) {
                                handleLevelTap(level)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 60)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showPaywall) {
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
            ) { EmptyView() }
        )
        .onAppear { loadCompletedLevels() }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Calm Journey 🌿")
                .font(.largeTitle.bold())
                .foregroundColor(Color(hex: "#6E63A4"))

            Text("Structured exercises to build lasting calm, based on proven therapy techniques.")
                .font(.system(.body, design: .rounded))
                .foregroundColor(Color(hex: "#7B6B9F"))
        }
        .multilineTextAlignment(.leading)
    }

    // MARK: - Logic

    private func handleLevelTap(_ level: CalmLevel) {
        HapticFeedback.light()
        if level.isLocked && !isPremiumUser {
            pendingLevel = level
            showPaywall = true
        } else {
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

// MARK: - ZigZag Level Row

struct ZigZagLevelRow: View {
    let level: CalmLevel
    let index: Int
    let isCompleted: Bool
    let isPremiumUser: Bool
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
                    .foregroundColor(Color(hex: "#6E63A4"))

                if !level.free && !isPremiumUser {
                    Image(systemName: "lock.fill")
                        .font(.system(.caption, weight: .medium))
                        .foregroundColor(Color(hex: "#7B6B9F").opacity(0.6))
                }
            }

            Text(level.summary)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(Color(hex: "#7B6B9F"))
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.4))
                .shadow(radius: 1)
        )
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
