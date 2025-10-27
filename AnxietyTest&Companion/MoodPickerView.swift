//
//  MoodPickerView.swift
//  AnxietyTest&Companion
//
//  Created by Mehmet Ali Kısacık on 26.10.2025.
//

import SwiftUI

struct MoodPickerView: View {
    @Binding var selectedMood: Mood?
    let onMoodSelected: (CompanionFaceView.Expression) -> Void
    
    enum Mood: String, CaseIterable {
        case verySad = "😔"
        case sad = "😕"
        case neutral = "😐"
        case good = "🙂"
        case veryHappy = "😄"
        
        var companionExpression: CompanionFaceView.Expression {
            switch self {
            case .veryHappy:
                return .happy
            case .good:
                return .happy
            case .neutral:
                return .neutral
            case .sad:
                return .mouthLeft
            case .verySad:
                return .mouthLeft
            }
        }
        
        var description: String {
            switch self {
            case .veryHappy:
                return "Very Happy"
            case .good:
                return "Good"
            case .neutral:
                return "Neutral"
            case .sad:
                return "Sad"
            case .verySad:
                return "Very Sad"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                ForEach(Mood.allCases, id: \.self) { mood in
                    Button(action: {
                        selectedMood = mood
                        HapticFeedback.light()
                        onMoodSelected(mood.companionExpression)
                    }) {
                        Text(mood.rawValue)
                            .font(.system(size: 40))
                            .scaleEffect(selectedMood == mood ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedMood)
                            .frame(width: 60, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selectedMood == mood ? Color.white.opacity(0.2) : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(selectedMood == mood ? Color.white.opacity(0.5) : Color.clear, lineWidth: 2)
                                    )
                            )
                            .scaleEffect(selectedMood == mood ? 1.05 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedMood)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel("\(mood.description) mood")
                    .accessibilityAddTraits(selectedMood == mood ? .isSelected : [])
                }
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var selectedMood: MoodPickerView.Mood? = nil

        var body: some View {
            VStack {
                MoodPickerView(selectedMood: $selectedMood) { expression in
                    print("Selected expression: \(expression)")
                }
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color(hex: "#6E63A4"), Color(hex: "#B5A7E0")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }

    return PreviewWrapper()
}
