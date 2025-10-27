//
//  CalmingLibraryView.swift
//  AnxietyTest&Companion
//
//  Displays the main calming library grid of cards.
//

import SwiftUI

struct CalmingLibraryView: View {
    private let activities = CalmingActivityStore.shared.activities
    @ObservedObject var sessionManager = CalmingSessionManager()

    var body: some View {
        ZStack {
            Color.themeBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Find Your Calm 🌿")
                        .font(.largeTitle.bold())
                        .foregroundColor(.themeText)

                    Text("Choose a small action to reset your mind.")
                        .foregroundColor(.themeText.opacity(0.8))

                    LazyVStack(spacing: 16) {
                        ForEach(activities) { activity in
                            NavigationLink(destination: destinationView(for: activity)) {
                                CalmingActivityCard(activity: activity)
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
            .padding(.horizontal, 24)
        }
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    private func destinationView(for activity: CalmingActivity) -> some View {
        switch activity.title {
        case "Breathing":
            GuidedBreathingView()
        case "Grounding":
            GroundingView()
        case "Journaling":
            JournalingView()
        case "Gratitude":
            GratitudeView()
        case "Affirmation":
            AffirmationView()
        default:
            CalmingCardView(activity: activity)
        }
    }
}

// MARK: - Subcomponent for Card Appearance
struct CalmingActivityCard: View {
    let activity: CalmingActivity

    var body: some View {
        HStack(spacing: 16) {
            Text(activity.emoji)
                .font(.system(size: 40))
                .frame(width: 60, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.themeCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.themeDivider, lineWidth: 1)
                        )
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.headline)
                    .foregroundColor(.themeText)
                Text(activity.description)
                    .font(.subheadline)
                    .foregroundColor(.themeText.opacity(0.7))
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.themeText.opacity(0.5))
                .font(.system(size: 16, weight: .medium))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.themeCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.themeDivider, lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .contentShape(Rectangle())
        .animation(.easeInOut(duration: 0.6), value: activity.id)
    }
}
