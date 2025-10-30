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
            // Background for the entire app
            Color.themeBackground
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
                    CalmJourneyView()
                }
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Journey")
                }
                .tag(2)
            }
            .accentColor(Color.themeText)
            .environment(\.managedObjectContext, viewContext)
        }
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
