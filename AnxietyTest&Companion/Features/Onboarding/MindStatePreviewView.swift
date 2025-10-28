//
//  MindStatePreviewView.swift
//  AnxietyTest&Companion
//
//  Created by Mehmet Ali Kısacık on 28.10.2025.
//

import SwiftUI
import Charts

struct MindStatePreviewView: View {
    @State private var showImprovedState = false
    @State private var pressInProgress = false
    @State private var holdProgress: Double = 0.0
    @State private var hapticTimer: Timer?
    @State private var isCompleted = false
    
    // Animated stat values
    @State private var anxiousThoughtsValue: Int = 68
    @State private var mindClarityValue: Int = 32
    @State private var calmMomentsValue: Int = 41
    @State private var selfCompassionValue: Int = 38
    
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            // Use app theme background
            Color.themeBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Title
                    Text("Your Current Mind State")
                        .font(.system(.title, design: .serif))
                        .fontWeight(.semibold)
                        .foregroundColor(.themeText)
                        .padding(.top, 60)
                    
                    // Subtitle
                    Text("See how tracking can transform your inner world")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.themeText.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 10)
                    
                    // MARK: - Chart (Emotional Balance)
                    ChartSection(
                        title: showImprovedState ? "With Tracking" : "Without Tracking",
                        subtitle: showImprovedState
                            ? "Tracking brings awareness. Awareness brings calm. You'll see patterns, triggers, and most importantly — progress."
                            : "When we don't track how we feel, emotions can feel overwhelming and unpredictable.",
                        data: showImprovedState ? improvedBalanceData : baseBalanceData,
                        lineColor: showImprovedState ? Color(hex: "#4CAF50") : Color(hex: "#9C27B0")
                    )
                    
                    // MARK: - Stats Cards
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(icon: "😰", title: "Anxious Thoughts", value: anxiousThoughtsValue)
                        StatCard(icon: "💭", title: "Mind Clarity", value: mindClarityValue)
                        StatCard(icon: "🧘‍♀️", title: "Calm Moments", value: calmMomentsValue)
                        StatCard(icon: "💗", title: "Self-Compassion", value: selfCompassionValue)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    
                    // MARK: - Fingerprint Interaction or Continue Button
                    if !isCompleted {
                        VStack(spacing: 12) {
                            ZStack {
                                // Progress ring
                                Circle()
                                    .stroke(Color.themeDivider.opacity(0.3), lineWidth: 4)
                                    .frame(width: 80, height: 80)
                                
                                Circle()
                                    .trim(from: 0, to: holdProgress)
                                    .stroke(Color.themeText, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                    .frame(width: 80, height: 80)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.linear(duration: 0.1), value: holdProgress)
                                
                                Image(systemName: "touchid")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 48, height: 48)
                                    .foregroundColor(pressInProgress ? .themeText : .themeDivider)
                                    .scaleEffect(pressInProgress ? 1.1 : 1.0)
                                    .animation(.easeInOut(duration: 0.3), value: pressInProgress)
                            }
                            .onLongPressGesture(minimumDuration: 3.0, pressing: { pressing in
                                handlePressChange(pressing: pressing)
                            }, perform: {
                                // Gesture completed - mark as finished
                                completeHold()
                            })
                            
                            Text(pressInProgress ? "Keep holding..." : "Tap and hold to see your potential")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.themeText.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .padding(.vertical, 24)
                    } else {
                        // MARK: - Continue Button (shown after completion)
                        Button(action: {
                            HapticFeedback.light()
                            onContinue()
                        }) {
                            Text("Continue")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(.themeText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.themeCard)
                                )
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .padding(.horizontal, 40)
                        .padding(.vertical, 24)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                    
                    Spacer()
                        .frame(height: 40)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func handlePressChange(pressing: Bool) {
        pressInProgress = pressing
        
        if pressing {
            // Start the transformation
            HapticFeedback.light()
            startProgressiveTransformation()
        } else {
            // User released early - reset everything
            if !isCompleted {
                stopProgressiveTransformation()
                withAnimation(.easeInOut(duration: 0.8)) {
                    showImprovedState = false
                    resetStatValues()
                    holdProgress = 0.0
                }
            }
        }
    }
    
    private func completeHold() {
        // Mark as completed
        isCompleted = true
        stopProgressiveTransformation()
        HapticFeedback.success()
        
        // Keep the improved state
        withAnimation(.easeInOut(duration: 0.5)) {
            showImprovedState = true
        }
    }
    
    private func startProgressiveTransformation() {
        holdProgress = 0.0
        
        // Animate chart
        withAnimation(.easeInOut(duration: 3.0)) {
            showImprovedState = true
        }
        
        // Start haptic feedback timer (every 0.5 seconds)
        hapticTimer?.invalidate()
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            HapticFeedback.light()
        }
        
        // Animate progress ring
        animateProgressRing()
        
        // Animate stat values progressively over 3 seconds
        animateStatValues()
    }
    
    private func animateProgressRing() {
        let steps = 30
        let interval = 3.0 / Double(steps)
        
        for step in 0...steps {
            let delay = interval * Double(step)
            let progress = Double(step) / Double(steps)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [self] in
                guard pressInProgress else { return }
                holdProgress = progress
            }
        }
    }
    
    private func stopProgressiveTransformation() {
        hapticTimer?.invalidate()
        hapticTimer = nil
        holdProgress = 0.0
    }
    
    private func animateStatValues() {
        // Initial values
        let startValues = (anxious: 68, clarity: 32, calm: 41, compassion: 38)
        let endValues = (anxious: 42, clarity: 71, calm: 79, compassion: 82)
        
        // Animate over 3 seconds with steps
        let steps = 30
        let interval = 3.0 / Double(steps)
        
        for step in 0...steps {
            let delay = interval * Double(step)
            let progress = Double(step) / Double(steps)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [self] in
                guard pressInProgress else { return }
                
                withAnimation(.easeOut(duration: interval)) {
                    anxiousThoughtsValue = Int(Double(startValues.anxious) + (Double(endValues.anxious - startValues.anxious) * progress))
                    mindClarityValue = Int(Double(startValues.clarity) + (Double(endValues.clarity - startValues.clarity) * progress))
                    calmMomentsValue = Int(Double(startValues.calm) + (Double(endValues.calm - startValues.calm) * progress))
                    selfCompassionValue = Int(Double(startValues.compassion) + (Double(endValues.compassion - startValues.compassion) * progress))
                }
            }
        }
    }
    
    private func resetStatValues() {
        anxiousThoughtsValue = 68
        mindClarityValue = 32
        calmMomentsValue = 41
        selfCompassionValue = 38
    }
    
    // MARK: - Example Data
    private var baseAnxietyData: [Double] { [40, 60, 80, 65, 75, 70, 68] }
    private var improvedAnxietyData: [Double] { [68, 58, 50, 45, 42, 40, 38] }
    
    private var baseBalanceData: [Double] { [20, 35, 48, 25, 40, 30, 42] }
    private var improvedBalanceData: [Double] { [60, 65, 70, 75, 78, 82, 85] }
}

// MARK: - Chart Section Component
struct ChartSection: View {
    var title: String
    var subtitle: String
    var data: [Double]
    var lineColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(.headline, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(.themeText)
            
            Chart {
                ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                    LineMark(
                        x: .value("Index", index),
                        y: .value("Value", value)
                    )
                    .foregroundStyle(lineColor)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                    .interpolationMethod(.catmullRom)
                }
            }
            .frame(height: 140)
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .animation(.easeInOut(duration: 1.0), value: data)
            
            Text(subtitle)
                .font(.system(.footnote, design: .rounded))
                .foregroundColor(.themeText.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.themeCard)
                .shadow(color: Color.themeCompanionOutline.opacity(0.08), radius: 6, x: 0, y: 2)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    var icon: String
    var title: String
    var value: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(icon)
                    .font(.title2)
                Spacer()
                Text("\(value)")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.themeText)
            }
            
            ProgressView(value: Double(value) / 100)
                .tint(.themeText)
                .scaleEffect(x: 1, y: 1.8, anchor: .center)
            
            Text(title)
                .font(.system(.caption, design: .rounded))
                .foregroundColor(.themeText.opacity(0.7))
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.themeCard)
                .shadow(color: Color.themeCompanionOutline.opacity(0.06), radius: 4, x: 0, y: 1)
        )
    }
}

#Preview {
    MindStatePreviewView(onContinue: {
        print("Continue tapped")
    })
}
