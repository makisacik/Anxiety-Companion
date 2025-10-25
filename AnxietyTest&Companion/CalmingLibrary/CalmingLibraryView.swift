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

            VStack(alignment: .leading, spacing: 20) {
                Text("Find Your Calm 🌿")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)

                Text("Choose a small action to reset your mind.")
                    .foregroundColor(.white.opacity(0.9))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(activities) { activity in
                            NavigationLink(destination: destinationView(for: activity)) {
                                CalmingActivityCard(activity: activity)
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    private func destinationView(for activity: CalmingActivity) -> some View {
        if activity.title == "Breathing" {
            GuidedBreathingView()
        } else {
            CalmingCardView(activity: activity)
        }
    }
}

// MARK: - Subcomponent for Card Appearance
struct CalmingActivityCard: View {
    let activity: CalmingActivity

    var body: some View {
        VStack(spacing: 12) {
            Text(activity.emoji)
                .font(.system(size: 40))
            Text(activity.title)
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(width: 150, height: 150)
        .background(Color(hex: activity.colorHex).opacity(0.9))
        .cornerRadius(20)
        .shadow(radius: 6)
        .overlay(RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(0.3), lineWidth: 1))
        .contentShape(Rectangle())
        .animation(.easeInOut(duration: 0.6), value: activity.id)
    }
}
