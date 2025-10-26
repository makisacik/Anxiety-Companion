//
//  MainTabView.swift
//  AnxietyTest&Companion
//
//  Created by Mehmet Ali Kısacık on 26.10.2025.
//

import SwiftUI
import CoreData

struct MainTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        ZStack {
            // Background gradient for the entire app
            LinearGradient(
                colors: [Color(hex: "#6E63A4"), Color(hex: "#B5A7E0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            
            TabView {
                AnxietyTestHomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(0)

                TrackingView()
                    .tabItem {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("Tracking")
                    }
                    .tag(1)

                NavigationStack {
                    CalmingLibraryView()
                }
                .tabItem {
                    Image(systemName: "leaf.fill")
                    Text("Calm")
                }
                .tag(2)

                NavigationStack {
                    CalmJourneyView()
                }
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Journey")
                }
                .tag(3)

                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                    }
                    .tag(4)
            }
            .accentColor(Color(hex: "#B5A7E0"))
            .environment(\.managedObjectContext, viewContext)
        }
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
