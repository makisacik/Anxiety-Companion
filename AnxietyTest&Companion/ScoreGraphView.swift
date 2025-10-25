//
//  ScoreGraphView.swift
//  AnxietyTest&Companion
//
//  Created by Mehmet Ali Kısacık on 26.10.2025.
//

import SwiftUI
import Charts

struct ScoreGraphView: View {
    let gad7Entries: [GAD7Entry]
    
    @State private var showGraph = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Calm Trend")
                .font(.system(.headline, design: .serif))
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            if gad7Entries.isEmpty {
                VStack(spacing: 8) {
                    Text("No data yet — take your first check-in to begin.")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    Text("Your progress will appear here once you start tracking.")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .frame(height: 160)
                .frame(maxWidth: .infinity)
            } else {
                Chart {
                    ForEach(sortedEntries, id: \.id) { entry in
                        LineMark(
                            x: .value("Date", entry.date ?? Date()),
                            y: .value("Score", entry.score)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color(hex: "#B5A7E0"))
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        
                        AreaMark(
                            x: .value("Date", entry.date ?? Date()),
                            y: .value("Score", entry.score)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "#B5A7E0").opacity(0.3), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        
                        PointMark(
                            x: .value("Date", entry.date ?? Date()),
                            y: .value("Score", entry.score)
                        )
                        .foregroundStyle(Color(hex: "#B5A7E0"))
                        .symbolSize(50)
                    }
                }
                .frame(height: 160)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 7)) { value in
                        AxisGridLine()
                            .foregroundStyle(.white.opacity(0.2))
                        AxisValueLabel()
                            .foregroundStyle(.white.opacity(0.7))
                            .font(.system(.caption2, design: .rounded))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                            .foregroundStyle(.white.opacity(0.2))
                        AxisValueLabel()
                            .foregroundStyle(.white.opacity(0.7))
                            .font(.system(.caption2, design: .rounded))
                    }
                }
                .chartYScale(domain: 0...21)
                .opacity(showGraph ? 1 : 0)
                .animation(.easeInOut(duration: 1.0), value: showGraph)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .onAppear {
            if !gad7Entries.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showGraph = true
                    HapticFeedback.soft()
                }
            }
        }
    }
    
    private var sortedEntries: [GAD7Entry] {
        gad7Entries.sorted { ($0.date ?? Date.distantPast) < ($1.date ?? Date.distantPast) }
    }
}

#Preview {
    VStack {
        ScoreGraphView(gad7Entries: [])
        
        Spacer()
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
