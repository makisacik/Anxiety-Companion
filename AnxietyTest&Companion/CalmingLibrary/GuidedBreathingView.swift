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
    @State private var showBreathingAnimation = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#6E63A4"), Color(hex: "#B5A7E0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()

            if !showBreathingAnimation {
                introView
            } else {
                breathingView
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

    private var introView: some View {
        VStack(spacing: 30) {
            Spacer()

            // Icon
            Image(systemName: "lungs.fill")
                .font(.system(size: 60))
                .foregroundColor(.white)
                .padding(30)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.2))
                )

            // Title
            Text("Guided Breathing")
                .font(.system(.largeTitle, design: .serif))
                .fontWeight(.bold)
                .foregroundColor(.white)

            // Scientific explanation
            VStack(spacing: 16) {
                benefitRow(
                    icon: "heart.fill",
                    title: "Activates Relaxation Response",
                    description: "Slow, deep breathing triggers your parasympathetic nervous system, reducing stress hormones like cortisol."
                )

                benefitRow(
                    icon: "brain.head.profile",
                    title: "Calms the Mind",
                    description: "Focusing on your breath helps quiet racing thoughts and brings your attention to the present moment."
                )

                benefitRow(
                    icon: "bolt.heart.fill",
                    title: "Lowers Heart Rate",
                    description: "Controlled breathing helps regulate your heart rate variability, promoting a sense of calm and well-being."
                )
            }
            .padding(.horizontal, 30)

            Spacer()

            // Start Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showBreathingAnimation = true
                }
                HapticManager.shared.soft()
            }) {
                HStack {
                    Image(systemName: "play.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Start Breathing Exercise")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                }
                .foregroundColor(Color(hex: "#6E63A4"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white)
                )
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
    }

    private func benefitRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color(hex: "#B5A7E0"))
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var breathingView: some View {
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
}
