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
                AnxietyTestHomeView()
            } else {
                OnboardingView()
            }
        }
    }
}
