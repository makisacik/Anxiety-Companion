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
                    AxisMarks(values: .stride(by: .day, count: xAxisStride)) { value in
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
                .chartXScale(domain: chartDateRange)
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
        // Group entries by date and take the last test of each day
        let calendar = Calendar.current
        let groupedByDate = Dictionary(grouping: gad7Entries) { entry in
            calendar.startOfDay(for: entry.date ?? Date.distantPast)
        }

        // For each date, take the entry with the latest time (most recent test of that day)
        let lastTestPerDay = groupedByDate.compactMapValues { entries in
            entries.max { ($0.date ?? Date.distantPast) < ($1.date ?? Date.distantPast) }
        }

        // Sort by date
        return lastTestPerDay.values.sorted { ($0.date ?? Date.distantPast) < ($1.date ?? Date.distantPast) }
    }

    private var xAxisStride: Int {
        let entryCount = sortedEntries.count
        switch entryCount {
        case 0...7:
            return 1  // Show every day for a week
        case 8...14:
            return 2  // Show every 2 days for 2 weeks
        case 15...30:
            return 3  // Show every 3 days for a month
        case 31...60:
            return 7  // Show every week for 2 months
        default:
            return 14 // Show every 2 weeks for longer periods
        }
    }

    private var chartDateRange: ClosedRange<Date> {
        guard !sortedEntries.isEmpty else {
            let today = Date()
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: today) ?? today
            return weekAgo...today
        }

        let firstDate = sortedEntries.first?.date ?? Date()
        let lastDate = sortedEntries.last?.date ?? Date()

        // Add some padding to the range for better visualization
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -1, to: firstDate) ?? firstDate
        let endDate = calendar.date(byAdding: .day, value: 1, to: lastDate) ?? lastDate

        return startDate...endDate
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
