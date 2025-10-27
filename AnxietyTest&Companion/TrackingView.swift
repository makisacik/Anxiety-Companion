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
                Color.themeBackground
                    .ignoresSafeArea(.all)

                ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Companion Section
                    CompanionSectionView(
                        gad7Entries: Array(gad7Entries),
                        moodEntries: Array(moodEntries)
                    )
                    
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
                .padding(.horizontal, 20)
                .padding(.top, 30)
                .padding(.bottom, 60)
                }
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
