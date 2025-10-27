//
//  AnxietyTest_CompanionApp.swift
//  AnxietyTest&Companion
//
//  Created by Mehmet Ali Kısacık on 26.10.2025.
//

import SwiftUI
import CoreData

@main
struct AnxietyTest_CompanionApp: App {
    let persistenceController = PersistenceController.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .forceLightMode()
                    .onAppear {
                        // Ensure reminders are properly scheduled after app launch
                        ReminderScheduler.shared.rescheduleIfNeeded()
                    }
            } else {
                OnboardingView()
                    .forceLightMode()
            }
        }
    }
}
