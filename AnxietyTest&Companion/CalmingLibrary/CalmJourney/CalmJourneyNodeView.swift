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
            // Outer glow for completed nodes
            if state == .completed {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.themeText.opacity(0.3),
                                Color.themeText.opacity(0.0)
                            ],
                            center: .center,
                            startRadius: 25,
                            endRadius: 50
                        )
                    )
                    .frame(width: 70, height: 70)
                    .blur(radius: 10)
            }
            
            // Main circle
            Circle()
                .fill(
                    state == .completed ? completedGradient :
                    state == .active ? activeGradient :
                    lockedGradient
                )
                .frame(width: 70, height: 70)
                .shadow(
                    color: state == .completed ? Color.themeText.opacity(0.4) :
                           state == .active ? Color.themeText.opacity(0.2) :
                           Color.black.opacity(0.15),
                    radius: state == .completed ? 12 : 8,
                    x: 0,
                    y: 4
                )
            
            // Inner content
            Group {
                if state == .completed {
                    Image(systemName: "checkmark")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.themeBackgroundPure)
                } else if state == .active {
                    Text("\(index)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.themeBackgroundPure)
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
    
    private var completedGradient: LinearGradient {
        LinearGradient(
            colors: [Color.themeText, Color.themeText.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var activeGradient: LinearGradient {
        LinearGradient(
            colors: [Color.themeText.opacity(0.8), Color.themeText.opacity(0.6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var lockedGradient: LinearGradient {
        LinearGradient(
            colors: [Color.themeDivider.opacity(0.6), Color.themeDivider.opacity(0.4)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
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
