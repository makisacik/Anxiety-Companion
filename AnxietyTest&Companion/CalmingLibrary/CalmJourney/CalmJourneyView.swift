//
//  CalmJourneyView.swift
//  AnxietyTest&Companion
//


import SwiftUI
import CoreData

private enum CalmJourneyDestination: Hashable {
    case level(CalmLevel)
    case report
}

struct CalmJourneyView: View {
    @StateObject private var dataStore = CalmJourneyDataStore.shared
    @AppStorage("isPremiumUser") private var isPremiumUser = false

    @State private var completedLevels: [Int] = []
    @State private var showPaywall = false
    @State private var navigationPath: [CalmJourneyDestination] = []
    @State private var showIncompleteAlert = false
    @State private var incompleteLevelsMessage = ""
    @State private var showSettings = false

    private let levelSpacing: CGFloat = 50

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color.themeBackground
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ZStack(alignment: .topTrailing) {
                            header
                                .padding(.horizontal, 24)
                                .padding(.top, 40)
                                .padding(.bottom, 30)
                            
                            Button(action: {
                                showSettings = true
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.themeText)
                            }
                            .padding(.trailing, 24)
                            .padding(.top, 10)
                        }

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
                                    if level.id == 5 || level.id == 10 {
                                        CalmReportPromoCard(
                                            level: level,
                                            isPremiumUser: isPremiumUser,
                                            isCompleted: checkCompletion(for: level.id),
                                            onViewReport: {
                                                handleReportCardTap(for: level.id)
                                            },
                                            onShowPaywall: { showPaywall = true }
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 60)
                        
                        // Footer decoration
                        Image("journey-footer")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .opacity(0.3)
                    }
                }

            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .alert(String(localized: "journey_complete_required"), isPresented: $showIncompleteAlert) {
                Button(String(localized: "journey_ok"), role: .cancel) { }
            } message: {
                Text(incompleteLevelsMessage)
            }
            .onAppear(perform: loadCompletedLevels)
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DebugDataFilled"))) { _ in
                loadCompletedLevels()
            }
            .navigationDestination(for: CalmJourneyDestination.self) { destination in
                switch destination {
                case .level(let level):
                    CalmLevelSessionView(
                        level: level,
                        isPremiumUser: isPremiumUser,
                        onLevelCompleted: { id in
                            if !completedLevels.contains(id) {
                                completedLevels.append(id)
                                saveCompletedLevels()
                            }
                        },
                        onViewReport: { navigateToReport() },
                        onShowPaywall: { showPaywall = true }
                    )
                case .report:
                    CalmReportGenerationView()
                }
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: "journey_title"))
                .font(.largeTitle.bold())
                .foregroundColor(.themeText)

            Text(String(localized: "journey_subtitle"))
                .font(.system(.body, design: .rounded))
                .foregroundColor(.themeText.opacity(0.8))
        }
        .multilineTextAlignment(.leading)
    }

    // MARK: - Helpers
    private func handleTap(_ level: CalmLevel) {
        HapticFeedback.light()
        if level.isLocked && !isPremiumUser {
            showPaywall = true
        } else {
            navigationPath.append(.level(level))
        }
    }

    private func handleReportCardTap(for levelId: Int) {
        HapticFeedback.light()
        
        // Check if user is premium
        if !isPremiumUser {
            showPaywall = true
            return
        }
        
        // Check if required levels are completed
        let isCompleted = checkCompletion(for: levelId)
        if !isCompleted {
            let missingLevels = getMissingLevels(for: levelId)
            incompleteLevelsMessage = String.localizedStringWithFormat(String(localized: "journey_missing_levels"), missingLevels)
            showIncompleteAlert = true
            return
        }
        
        // All good - navigate to report
        navigateToReport()
    }

    private func navigateToReport() {
        if let last = navigationPath.last, case .report = last {
            return
        }
        navigationPath.append(.report)
    }

    private func checkCompletion(for id: Int) -> Bool {
        if id == 5 { return (1...5).allSatisfy { completedLevels.contains($0) } }
        if id == 10 { return (1...10).allSatisfy { completedLevels.contains($0) } }
        return false
    }
    
    private func getMissingLevels(for levelId: Int) -> String {
        let requiredLevels: [Int]
        if levelId == 5 {
            requiredLevels = Array(1...5)
        } else {
            requiredLevels = Array(1...10)
        }
        
        let missing = requiredLevels.filter { !completedLevels.contains($0) }
        
        if missing.isEmpty {
            return String(localized: "journey_all_levels")
        } else if missing.count == 1 {
            return String.localizedStringWithFormat(String(localized: "journey_level"), missing[0])
        } else if missing.count == 2 {
            let level1 = String.localizedStringWithFormat(String(localized: "journey_level"), missing[0])
            let level2 = String.localizedStringWithFormat(String(localized: "journey_level"), missing[1])
            return String.localizedStringWithFormat(String(localized: "journey_levels"), level1, level2)
        } else {
            let allButLast = missing.dropLast().map { String.localizedStringWithFormat(String(localized: "journey_level"), $0) }.joined(separator: ", ")
            return String.localizedStringWithFormat(String(localized: "journey_levels_list"), allButLast, missing.last!)
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
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 6) {
                Text(level.title)
                    .font(.system(.title3, design: .serif))
                    .fontWeight(.semibold)
                    .foregroundColor(.themeText)

                Text(level.summary)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.themeText.opacity(0.7))
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.themeCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.themeDivider, lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            if !level.free && !isPremiumUser {
                Image(systemName: "lock.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.themeText.opacity(0.5))
                    .padding(12)
            }
        }
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
