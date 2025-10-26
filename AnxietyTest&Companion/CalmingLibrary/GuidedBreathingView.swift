//
//  GuidedBreathingView.swift
//  AnxietyTest&Companion
//
//  Combines companion + breathing animation for guided mode.
//

import SwiftUI

struct GuidedBreathingView: View {
    @StateObject private var manager = BreathingManager()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#6E63A4"), Color(hex: "#B5A7E0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()

            VStack(spacing: 30) {
                BreathingCircleViewCustom(
                    isExpanded: $manager.isExpanded,
                    onPhaseChange: manager.updatePhase
                )

                Button("Finish Session 🌿") {
                    manager.finishSession()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        dismiss()
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 40)
                .padding(.vertical, 10)
                .background(Color(hex: "#B5A7E0"))
                .cornerRadius(30)
                .foregroundColor(.white)
                .opacity(manager.isFinished ? 1 : 0)
                .animation(.easeInOut, value: manager.isFinished)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .medium))
                }
            }
        }
    }
}
