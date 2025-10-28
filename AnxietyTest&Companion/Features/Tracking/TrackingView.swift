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
    @State private var showIntroOverlay = false
    @State private var selectedDay: Date? = nil
    
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
                        Text("Your Progress 📊")
                            .font(.largeTitle.bold())
                            .foregroundColor(.themeText)

                        Text("Track your anxiety patterns and see how you're improving over time.")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.themeText.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    .padding(.bottom, 30)
                    .overlay(alignment: .trailing) {
                        Image("tracking-header")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .opacity(0.3)
                            .offset(y: -30)
                            .allowsHitTesting(false)
                    }
                    
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
                }
                .navigationBarHidden(true)
                .onAppear {
                    checkForIntroOverlay()
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
