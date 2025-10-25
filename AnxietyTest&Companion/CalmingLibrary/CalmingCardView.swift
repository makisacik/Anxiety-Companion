//
//  CalmingCardView.swift
//  AnxietyTest&Companion
//
//  Displays details and instruction for one calming activity.
//

import SwiftUI

struct CalmingCardView: View {
    let activity: CalmingActivity
    @Environment(\.dismiss) private var dismiss
    @State private var showCompleteMessage = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#6E63A4"), Color(hex: "#B5A7E0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Text(activity.emoji)
                    .font(.system(size: 60))

                Text(activity.title)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)

                Text(activity.description)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.9))
                    .font(.title3)
                    .padding(.horizontal)

                Spacer()

                if showCompleteMessage {
                    Text("Nice work 🌿 You gave yourself a calm moment.")
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                }

                Button(action: {
                    HapticManager.shared.success()
                    withAnimation { showCompleteMessage = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        dismiss()
                    }
                }) {
                    Text("Done")
                        .font(.headline)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(Color(hex: "#B5A7E0"))
                        .cornerRadius(30)
                        .foregroundColor(.white)
                }
            }
            .padding(.vertical, 40)
        }
        .navigationBarBackButtonHidden(true)
    }
}
