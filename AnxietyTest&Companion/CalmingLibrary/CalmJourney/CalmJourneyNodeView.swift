//
//  CalmJourneyNodeView.swift
//  AnxietyTest&Companion
//
//  Circular node component for the journey path
//

import SwiftUI

enum NodeState {
    case locked
    case active
    case completed
}

struct CalmJourneyNodeView: View {
    let level: CalmLevel
    let state: NodeState
    let index: Int
    @State private var animateIn: Bool = false
    
    var body: some View {
        ZStack {
            // Background image based on completion state
            if state == .completed {
                Image("journey-level-done")
                    .renderingMode(.original)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 70, height: 70)
            } else {
                Image("journey-level-number")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                
                // Overlay content for non-completed states
                if state == .active {
                    Text("\(index)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.themeText)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.themeText.opacity(0.4))
                }
            }
        }
        .scaleEffect(animateIn ? 1.0 : 0.8)
        .opacity(animateIn ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.1)) {
                animateIn = true
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        CalmJourneyNodeView(
            level: CalmJourneyDataStore.shared.levels[0],
            state: .completed,
            index: 1
        )
        
        CalmJourneyNodeView(
            level: CalmJourneyDataStore.shared.levels[0],
            state: .active,
            index: 2
        )
        
        CalmJourneyNodeView(
            level: CalmJourneyDataStore.shared.levels[0],
            state: .locked,
            index: 3
        )
    }
    .padding()
    .background(
        LinearGradient(
            colors: [Color(hex: "#E6E6FA"), Color(hex: "#FFE4E1")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
