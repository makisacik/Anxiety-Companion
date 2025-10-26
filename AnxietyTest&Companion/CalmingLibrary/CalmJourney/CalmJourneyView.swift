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

    private let verticalSpacing: CGFloat = 120
    private let horizontalOffset: CGFloat = 40

    private var nodePositions: [PathNodePosition] {
        PathNodePosition.positions(
            count: dataStore.levels.count,
            verticalSpacing: verticalSpacing,
            horizontalOffset: horizontalOffset
        )
    }

    var body: some View {
        ZStack {
            // Background gradient - lavender to blush
            LinearGradient(
                colors: [Color(hex: "#E6E6FA"), Color(hex: "#FFE4E1")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                ZStack(alignment: .topLeading) {
                    // Background connecting path
                    GeometryReader { geometry in
                        CalmJourneyPathShape(
                            nodePositions: nodePositions,
                            nodeRadius: 35
                        )
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#C8A2C8").opacity(0.6),
                                    Color(hex: "#B5A7E0").opacity(0.4)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
                        )
                        .shadow(color: Color(hex: "#C8A2C8").opacity(0.3), radius: 8, x: 0, y: 2)
                        .frame(height: calculatePathHeight(), alignment: .topLeading)
                    }

                    // Content layers
                    VStack(spacing: 0) {
                        // Header
                        headerSection
                            .padding(.bottom, 40)
                            .zIndex(1)

                        // Levels with path nodes
                        ForEach(Array(dataStore.levels.enumerated()), id: \.element.id) { index, level in
                            levelRowView(level: level, index: index)
                                .padding(.bottom, verticalSpacing - 70)
                                .padding(.horizontal, 24)
                        }

                        // Extra space at bottom
                        Spacer(minLength: 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showPaywall, onDismiss: {
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

    private func calculatePathHeight() -> CGFloat {
        guard dataStore.levels.count > 0 else { return 0 }
        return CGFloat(dataStore.levels.count - 1) * verticalSpacing + 200
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Calm Journey 🌿")
                .font(.largeTitle.bold())
                .foregroundColor(Color(hex: "#6E63A4"))

            Text("Structured exercises to build lasting calm, based on proven therapy techniques.")
                .font(.system(.body, design: .rounded))
                .foregroundColor(Color(hex: "#7B6B9F"))
                .fixedSize(horizontal: false, vertical: true)

            // Premium status indicator
            if isPremiumUser {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(Color(hex: "#B5A7E0"))
                    Text("Premium Unlocked")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(Color(hex: "#7B6B9F"))
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
        .padding(.horizontal, 24)
    }

    private func levelRowView(level: CalmLevel, index: Int) -> some View {
        let position = nodePositions[index]
        let isCompleted = completedLevels.contains(level.id)
        let isAccessible = level.free || isPremiumUser
        let nodeState: NodeState = isCompleted ? .completed : (isAccessible ? .active : .locked)

        return HStack(alignment: .center, spacing: 20) {
            // Node with offset
            CalmJourneyNodeView(level: level, state: nodeState, index: level.id)
                .offset(x: position.xOffset, y: 0)

            Spacer()

            // Level info
            VStack(alignment: .trailing, spacing: 8) {
                Button(action: {
                    handleLevelTap(level)
                }) {
                    VStack(alignment: .trailing, spacing: 6) {
                        HStack {
                            Spacer()
                            Text(level.title)
                                .font(.system(.title3, design: .serif))
                                .fontWeight(.semibold)
                                .foregroundColor(isAccessible ? Color(hex: "#6E63A4") : Color(hex: "#7B6B9F").opacity(0.6))

                            if !isAccessible {
                                Image(systemName: "lock.fill")
                                    .font(.system(.caption, weight: .medium))
                                    .foregroundColor(Color(hex: "#7B6B9F").opacity(0.6))
                            }
                        }

                        Text(level.summary)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(isAccessible ? Color(hex: "#7B6B9F") : Color(hex: "#7B6B9F").opacity(0.5))
                            .multilineTextAlignment(.trailing)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack {
                            Spacer()
                            Text("\(level.exercises.count) exercises")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(isAccessible ? Color(hex: "#7B6B9F").opacity(0.7) : Color(hex: "#7B6B9F").opacity(0.4))

                            if isAccessible {
                                Image(systemName: "chevron.right")
                                    .font(.system(.caption, weight: .medium))
                                    .foregroundColor(Color(hex: "#7B6B9F").opacity(0.6))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .frame(minWidth: 200, alignment: .trailing)
        }
    }

    private func handleLevelTap(_ level: CalmLevel) {
        HapticFeedback.light()
        print("🔓 Tapped level: \(level.title), isLocked: \(level.isLocked), isPremium: \(isPremiumUser)")

        if level.isLocked && !isPremiumUser {
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

#Preview {
    CalmJourneyView()
}
