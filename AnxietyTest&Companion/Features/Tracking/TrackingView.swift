//
//  TrackingView.swift
//  AnxietyTest&Companion
//
//  Created by Mehmet Ali Kısacık on 26.10.2025.
//

import SwiftUI
import CoreData

struct TrackingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("isPremiumUser") private var isPremiumUser = false
    @State private var showIntroOverlay = false
    @State private var selectedDay: Date? = nil
    @State private var showPaywall = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \GAD7Entry.date, ascending: false)],
        animation: .default
    )
    private var gad7Entries: FetchedResults<GAD7Entry>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MoodEntry.date, ascending: false)],
        animation: .default
    )
    private var moodEntries: FetchedResults<MoodEntry>
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                ZStack {
                    Color.themeBackground
                        .ignoresSafeArea(.all)
                    
                    // Footer background decoration
                    VStack {
                        Spacer()
                        Image("tracking-footer")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .opacity(0.3)
                    }
                    .ignoresSafeArea()
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header with decorative background image (does not affect layout height)
                        VStack(alignment: .leading, spacing: 16) {
                            Text(String(localized: "tracking_title"))
                                .font(.largeTitle.bold())
                                .foregroundColor(.themeText)

                            Text(String(localized: "tracking_subtitle"))
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(.themeText.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 24)
                        .padding(.top, 40)
                        .padding(.bottom, 6)
                        .overlay(alignment: .trailing) {
                            Image("tracking-header")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 120)
                                .opacity(0.3)
                                .offset(y: -30)
                                .allowsHitTesting(false)
                        }

                        // Promo card shown when not premium
                        if !isPremiumUser {
                            PremiumTrackingPromoCard {
                                HapticFeedback.soft()
                                showPaywall = true
                            }
                            .padding(.horizontal, 24)
                        }

                        // Content section (blurred and non-interactive when not premium)
                        VStack(spacing: 24) {
                            // Summary Card
                            SummaryCardView(gad7Entries: Array(gad7Entries))

                            // Score Graph
                            ScoreGraphView(gad7Entries: Array(gad7Entries))

                            // Calendar View
                            CalendarGridView(
                                gad7Entries: Array(gad7Entries),
                                moodEntries: Array(moodEntries),
                                selectedDay: $selectedDay
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 60)
                        .blur(radius: isPremiumUser ? 0 : 8)
                        .allowsHitTesting(isPremiumUser)
                    }
                }
                .navigationBarHidden(true)
                .onAppear {
                    // Only show intro overlay to premium users
                    if isPremiumUser { checkForIntroOverlay() }
                    DataManager.shared.migrateFromAppStorage()
                }
                .overlay(
                    // Intro Overlay
                    Group {
                        if showIntroOverlay {
                            IntroOverlayView(showIntro: $showIntroOverlay)
                                .transition(.opacity)
                                .zIndex(1)
                        }
                    }
                )
                .sheet(isPresented: $showPaywall) {
                    PaywallView()
                }
            }
        }
    }
    
    private func checkForIntroOverlay() {
        let hasShownIntro = UserDefaults.standard.bool(forKey: "trackingIntroShown")
        if !hasShownIntro {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    showIntroOverlay = true
                }
            }
        }
    }
}

#Preview {
    TrackingView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

// MARK: - Premium Promo Card

private struct PremiumTrackingPromoCard: View {
    var onUnlock: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 12) {
                Image("chart")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "tracking_unlock_title"))
                        .font(.system(.title3, design: .rounded)).bold()
                        .foregroundColor(.themeText)
                    Text(String(localized: "tracking_unlock_message"))
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.themeText.opacity(0.8))
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                promoRow(icon: "chart.line.uptrend.xyaxis", text: String(localized: "tracking_promo_gad7_trends"))
                promoRow(icon: "calendar", text: String(localized: "tracking_promo_calendar"))
                promoRow(icon: "bell", text: String(localized: "tracking_promo_reminders"))
            }

            Button(action: onUnlock) {
                HStack {
                    Text(String(localized: "tracking_unlock_button"))
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.themeBackgroundPure)
                    Spacer()
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.themeBackgroundPure)
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [Color.themeText, Color.themeCompanionDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.themeBackgroundPure.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: Color.themeText.opacity(0.18), radius: 8, x: 0, y: 5)
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.themeCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.themeDivider, lineWidth: 1)
                )
        )
    }

    private func promoRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.themeText)
                .frame(width: 22)
            Text(text)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.themeText)
        }
    }
}
