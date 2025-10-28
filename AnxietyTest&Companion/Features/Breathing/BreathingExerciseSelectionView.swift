//
//  BreathingExerciseSelectionView.swift
//  AnxietyTest&Companion
//
//  Created by GitHub Copilot on 28.10.2025.
//

import SwiftUI

struct BreathingExerciseSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (BreathingExerciseType) -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "wind")
                            .font(.system(size: 50))
                            .foregroundColor(.themeText)
                            .padding(20)
                            .background(
                                Circle()
                                    .fill(Color.themeCard)
                            )
                        
                        Text("Choose Your Breathing")
                            .font(.system(.title2, design: .serif))
                            .fontWeight(.semibold)
                            .foregroundColor(.themeText)
                        
                        Text("Select a breathing pattern that feels right for you")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.themeText.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    // Exercise Cards
                    ForEach(BreathingExerciseType.allCases) { exerciseType in
                        exerciseCard(for: exerciseType)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color.themeBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.themeText)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
        }
    }
    
    private func exerciseCard(for type: BreathingExerciseType) -> some View {
        Button(action: {
            HapticFeedback.light()
            onSelect(type)
            dismiss()
        }) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: type.icon)
                    .font(.system(size: 28))
                    .foregroundColor(.themeText)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(Color.themeBackground)
                    )
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(type.rawValue)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.themeText)
                    
                    Text(type.description)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.themeText.opacity(0.7))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.themeText.opacity(0.5))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.themeCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.themeDivider, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
