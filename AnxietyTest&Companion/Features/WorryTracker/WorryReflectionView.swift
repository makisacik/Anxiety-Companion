//
//  WorryReflectionView.swift
//  AnxietyTest&Companion
//
//  Created by GitHub Copilot on 29.10.2025.
//

import SwiftUI

struct WorryReflectionView: View {
    @Environment(\.dismiss) private var dismiss
    var worry: WorryLog
    @ObservedObject var viewModel: WorryTrackerViewModel
    
    @State private var answered = false
    @State private var wasBetter: Bool? = nil
    @State private var showMessage = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green.opacity(0.7))
                        .padding(.top, 30)
                    
                    Text(String(localized: "worry_reflection_title"))
                        .font(.system(.largeTitle, design: .serif))
                        .fontWeight(.bold)
                        .foregroundColor(.themeText)
                    
                    Text(String(localized: "worry_reflection_subtitle"))
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.themeText.opacity(0.7))
                }
                
                // Original Worry Card
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(.themeText.opacity(0.6))
                        
                        Text(worry.dateCreated?.formatted(date: .abbreviated, time: .shortened) ?? "")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.themeText.opacity(0.6))
                        
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(String(localized: "worry_reflection_you_were_worried"))
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.themeText.opacity(0.7))
                            .textCase(.uppercase)
                        
                        Text("\"\(worry.worryText ?? "")\"")
                            .font(.system(.title3, design: .rounded))
                            .foregroundColor(.themeText)
                            .multilineTextAlignment(.leading)
                            .padding(.vertical, 8)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Control thought if exists
                    if let control = worry.controlThought, !control.isEmpty {
                        Divider()
                            .background(Color.themeDivider)
                        
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "hand.point.right.fill")
                                .font(.caption)
                                .foregroundColor(.green.opacity(0.7))
                                .padding(.top, 2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(String(localized: "worry_reflection_what_control"))
                                    .font(.system(.caption2, design: .rounded))
                                    .foregroundColor(.themeText.opacity(0.6))
                                    .textCase(.uppercase)
                                
                                Text(control)
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(.themeText.opacity(0.8))
                                    .italic()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Intensity
                    HStack {
                        Text(String(localized: "worry_reflection_intensity"))
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.themeText.opacity(0.6))
                        
                        HStack(spacing: 3) {
                            ForEach(0..<Int(worry.intensity), id: \.self) { _ in
                                Circle()
                                    .fill(intensityColor(for: Int(worry.intensity)))
                                    .frame(width: 5, height: 5)
                            }
                        }
                        
                        Text(String.localizedStringWithFormat(String(localized: "worry_tracker_intensity"), Int(worry.intensity)))
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.themeText.opacity(0.6))
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.themeCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.themeDivider, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
                
                // Question
                if !answered {
                    VStack(spacing: 24) {
                        Text(String(localized: "worry_reflection_question"))
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.themeText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // Answer Buttons
                        VStack(spacing: 12) {
                            Button {
                                answerWorry(wasBetter: true)
                            } label: {
                                HStack {
                                    Image(systemName: "sun.max.fill")
                                        .font(.title2)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(String(localized: "worry_reflection_better_yes"))
                                            .font(.system(.body, design: .rounded))
                                            .fontWeight(.semibold)
                                        
                                        Text(String(localized: "worry_reflection_better_okay"))
                                            .font(.system(.caption, design: .rounded))
                                            .opacity(0.8)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.right")
                                }
                                .foregroundColor(.white)
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.green, Color.green.opacity(0.8)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .shadow(color: Color.green.opacity(0.3), radius: 10, y: 5)
                            }
                            .buttonStyle(ScaleButtonStyle())
                            
                            Button {
                                answerWorry(wasBetter: false)
                            } label: {
                                HStack {
                                    Image(systemName: "cloud.fill")
                                        .font(.title2)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(String(localized: "worry_reflection_better_no"))
                                            .font(.system(.body, design: .rounded))
                                            .fontWeight(.semibold)
                                        
                                        Text(String(localized: "worry_reflection_better_tough"))
                                            .font(.system(.caption, design: .rounded))
                                            .opacity(0.8)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.right")
                                }
                                .foregroundColor(.white)
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.orange, Color.orange.opacity(0.8)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .shadow(color: Color.orange.opacity(0.3), radius: 10, y: 5)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // Success Message
                if showMessage {
                    VStack(spacing: 16) {
                        Image(systemName: wasBetter == true ? "checkmark.circle.fill" : "heart.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(wasBetter == true ? .green : .orange)
                        
                        Text(wasBetter == true
                             ? String(localized: "worry_reflection_success_better_title")
                             : String(localized: "worry_reflection_success_okay_title"))
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.themeText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                        
                        Text(wasBetter == true
                             ? String(localized: "worry_reflection_success_better_message")
                             : String(localized: "worry_reflection_success_okay_message"))
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.themeText.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    .padding(.vertical, 30)
                    .transition(.opacity.combined(with: .scale))
                }
                
                Spacer(minLength: 40)
            }
            .padding(.bottom, 40)
        }
        .background(
            ZStack {
                Color.themeBackground
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    Image("tree-footer")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .opacity(0.15)
                }
                .ignoresSafeArea()
            }
        )
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Actions
    
    private func answerWorry(wasBetter: Bool) {
        self.wasBetter = wasBetter
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            answered = true
        }
        
        HapticFeedback.soft()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showMessage = true
            }
        }
        
        viewModel.answerWorry(worry, wasBetter: wasBetter)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            dismiss()
        }
    }
    
    // MARK: - Helpers
    
    private func intensityColor(for intensity: Int) -> Color {
        switch intensity {
        case 0...3:
            return .green
        case 4...6:
            return .yellow
        case 7...8:
            return .orange
        default:
            return .red
        }
    }
}
