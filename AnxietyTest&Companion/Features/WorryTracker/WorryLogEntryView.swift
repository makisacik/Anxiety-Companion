//
//  WorryLogEntryView.swift
//  AnxietyTest&Companion
//
//  Created by GitHub Copilot on 29.10.2025.
//

import SwiftUI

struct WorryLogEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: WorryTrackerViewModel
    
    @State private var worryText = ""
    @State private var controlThought = ""
    @State private var intensity = 5.0
    @State private var reminderHours = 3
    
    private let reminderOptions = [
        (hours: 3, label: "In 3 hours"),
        (hours: 6, label: "In 6 hours"),
        (hours: 12, label: "In 12 hours"),
        (hours: 24, label: "Tomorrow")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Header Icon
                Image(systemName: "bubble.left.and.exclamationmark")
                    .font(.system(size: 50))
                    .foregroundColor(.themeText.opacity(0.7))
                    .padding(.top, 20)
                
                // Main Question
                VStack(spacing: 12) {
                    Text("What are you worried about now?")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.themeText)
                        .multilineTextAlignment(.center)
                    
                    Text("Express your concern freely")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.themeText.opacity(0.6))
                }
                .padding(.horizontal)
                
                // Worry Text Input
                VStack(alignment: .leading, spacing: 8) {
                    TextField("e.g., Tomorrow's presentation", text: $worryText, axis: .vertical)
                        .font(.system(.body, design: .rounded))
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.themeBackgroundPure)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.themeDivider, lineWidth: 1)
                                )
                        )
                        .lineLimit(3...6)
                    
                    Text("\(worryText.count)/200")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(.themeText.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal, 20)
                .onChange(of: worryText) { newValue in
                    if newValue.count > 200 {
                        worryText = String(newValue.prefix(200))
                    }
                }
                
                // Intensity Slider
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Text("How strong does this feel?")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.themeText)
                        
                        HStack {
                            Text("\(Int(intensity))")
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(intensityColor(for: Int(intensity)))
                            
                            Text("/ 10")
                                .font(.system(.title3, design: .rounded))
                                .foregroundColor(.themeText.opacity(0.6))
                        }
                        
                        Text(intensityLabel(for: Int(intensity)))
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.themeText.opacity(0.7))
                    }
                    
                    Slider(value: $intensity, in: 0...10, step: 1)
                        .tint(intensityColor(for: Int(intensity)))
                        .padding(.horizontal)
                    
                    HStack {
                        Text("😌 Mild")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(.themeText.opacity(0.6))
                        
                        Spacer()
                        
                        Text("Intense 😰")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(.themeText.opacity(0.6))
                    }
                    .padding(.horizontal)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.themeCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.themeDivider, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
                
                // Control Thought (Optional)
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "hand.point.right.fill")
                            .foregroundColor(.green.opacity(0.7))
                        
                        Text("One thing I can control is...")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.themeText)
                        
                        Text("(optional)")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.themeText.opacity(0.5))
                    }
                    
                    TextField("e.g., How I prepare for it", text: $controlThought)
                        .font(.system(.body, design: .rounded))
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.themeBackgroundPure)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.themeDivider, lineWidth: 1)
                                )
                        )
                }
                .padding(.horizontal, 20)
                
                // Reminder Picker
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.themeText.opacity(0.7))
                        
                        Text("Remind me to check in")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.themeText)
                    }
                    
                    VStack(spacing: 8) {
                        ForEach(reminderOptions, id: \.hours) { option in
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    reminderHours = option.hours
                                }
                                HapticFeedback.light()
                            } label: {
                                HStack {
                                    Text(option.label)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundColor(.themeText)
                                    
                                    Spacer()
                                    
                                    if reminderHours == option.hours {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundColor(.themeDivider)
                                    }
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(reminderHours == option.hours ? Color.green.opacity(0.1) : Color.themeBackgroundPure)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(reminderHours == option.hours ? Color.green.opacity(0.5) : Color.themeDivider, lineWidth: reminderHours == option.hours ? 2 : 1)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Save Button
                Button {
                    saveWorry()
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                        Text("Save Worry")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.themeBackgroundPure)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(worryText.isEmpty ? Color.themeDivider : Color.themeText)
                    )
                    .shadow(color: worryText.isEmpty ? Color.clear : Color.themeText.opacity(0.3), radius: 10, y: 4)
                }
                .disabled(worryText.isEmpty)
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .padding(.vertical, 20)
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
        .navigationTitle("Log Worry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.themeText.opacity(0.6))
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func saveWorry() {
        guard !worryText.isEmpty else { return }
        
        let reminderDate = Calendar.current.date(byAdding: .hour, value: reminderHours, to: Date()) ?? Date()
        
        viewModel.addWorry(
            text: worryText,
            control: controlThought.isEmpty ? nil : controlThought,
            intensity: Int(intensity),
            reminderDate: reminderDate
        )
        
        HapticFeedback.soft()
        dismiss()
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
    
    private func intensityLabel(for intensity: Int) -> String {
        switch intensity {
        case 0...2:
            return "Barely noticeable"
        case 3...4:
            return "Mild concern"
        case 5...6:
            return "Moderate worry"
        case 7...8:
            return "Strong anxiety"
        case 9...10:
            return "Overwhelming"
        default:
            return ""
        }
    }
}
