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
            LinearGradient(
                colors: [Color(hex: "#6E63A4"), Color(hex: "#B5A7E0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Find Your Calm 🌿")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)

                    Text("Choose a small action to reset your mind.")
                        .foregroundColor(.white.opacity(0.9))

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
                .background(Color.white.opacity(0.2))
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(activity.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.6))
                .font(.system(size: 16, weight: .medium))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(hex: activity.colorHex).opacity(0.9))
        .cornerRadius(16)
        .shadow(radius: 4)
        .overlay(RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.3), lineWidth: 1))
        .contentShape(Rectangle())
        .animation(.easeInOut(duration: 0.6), value: activity.id)
    }
}
