//
//  CalmLevelCompletionCard.swift
//  AnxietyTest&Companion
//
//  Session completion screen with companion celebration and action buttons.
//

import SwiftUI

struct CalmLevelCompletionCard: View {
    let level: CalmLevel
    let isPremiumUser: Bool
    let onRepeatSession: () -> Void
    let onBackToJourney: () -> Void
    let onViewReport: (() -> Void)?
    let onShowPaywall: (() -> Void)?

    @State private var isVisible = false

    private var isMilestoneLevel: Bool {
        return level.id == 5 || level.id == 10
    }

    init(level: CalmLevel, isPremiumUser: Bool, onRepeatSession: @escaping () -> Void, onBackToJourney: @escaping () -> Void, onViewReport: (() -> Void)? = nil, onShowPaywall: (() -> Void)? = nil) {
        self.level = level
        self.isPremiumUser = isPremiumUser
        self.onRepeatSession = onRepeatSession
        self.onBackToJourney = onBackToJourney
        self.onViewReport = onViewReport
        self.onShowPaywall = onShowPaywall
    }

    var body: some View {
        regularCompletionView
            .onAppear {
                // Show regular completion for all levels
                HapticFeedback.success()
                withAnimation(.easeInOut(duration: 0.6)) {
                    isVisible = true
                }
            }
    }

    private var regularCompletionView: some View {
        VStack(spacing: 32) {
            Spacer()

            // Celebration content
            VStack(spacing: 24) {
                Text(String(localized: "completion_congrats"))
                    .font(.title2.bold())
                    .foregroundColor(.themeText)
                    .multilineTextAlignment(.center)

                CompanionFaceView(expression: .happy)
                    .frame(width: 120, height: 120)

                Text(String(localized: "completion_breath"))
                    .font(.body)
                    .foregroundColor(.themeText.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Spacer()

            // Action buttons
            VStack(spacing: 16) {
                Button(action: {
                    HapticFeedback.light()
                    onBackToJourney()
                }) {
                    HStack {
                        Image(systemName: "house.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text(String(localized: "completion_back_to_journey"))
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.themeText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.themeCard)
                            .shadow(radius: 3)
                    )
                }
                .buttonStyle(ScaleButtonStyle())

                Button(action: {
                    HapticFeedback.light()
                    onRepeatSession()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 18, weight: .semibold))
                        Text(String(localized: "completion_repeat_session"))
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.themeText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.themeDivider, lineWidth: 1)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 50)
        }
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
    }
}

#Preview {
    ZStack {
        Color.themeBackground
            .ignoresSafeArea()

        CalmLevelCompletionCard(
            level: CalmJourneyDataStore.shared.levels[0],
            isPremiumUser: true,
            onRepeatSession: {},
            onBackToJourney: {}
        )
    }
}
