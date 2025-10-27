//
//  CalendarGridView.swift
//  AnxietyTest&Companion
//
//  Created by Mehmet Ali Kısacık on 26.10.2025.
//

import SwiftUI

struct CalendarGridView: View {
    let gad7Entries: [GAD7Entry]
    let moodEntries: [MoodEntry]
    @Binding var selectedDay: Date?
    
    @State private var currentMonth = Date()
    @State private var showDayDetail = false
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Check-ins")
                    .font(.system(.headline, design: .serif))
                    .fontWeight(.semibold)
                    .foregroundColor(.themeText)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.themeText)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    Text(monthYearString)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.themeText)
                        .frame(minWidth: 100)
                    
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.themeText)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            
            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                // Day headers
                ForEach(Array(["S", "M", "T", "W", "T", "F", "S"].enumerated()), id: \.offset) { index, day in
                    Text(day)
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.themeText.opacity(0.7))
                        .frame(height: 20)
                }
                
                // Calendar days
                ForEach(daysInMonth, id: \.self) { date in
                    CalendarDayView(
                        date: date,
                        gad7Entry: gad7EntryForDate(date),
                        moodEntry: moodEntryForDate(date),
                        isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month),
                        isToday: calendar.isDateInToday(date)
                    )
                    .onTapGesture {
                        selectedDay = date
                        showDayDetail = true
                        HapticFeedback.light()
                    }
                }
            }
            
            // Legend
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.themeText.opacity(0.3))
                        .frame(width: 8, height: 8)
                    Text("Calm")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(.themeText.opacity(0.7))
                }
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.themeText)
                        .frame(width: 8, height: 8)
                    Text("Moderate")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(.themeText.opacity(0.7))
                }
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.themeCompanionOutline)
                        .frame(width: 8, height: 8)
                    Text("High")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(.themeText.opacity(0.7))
                }
                
                Spacer()
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
        .sheet(isPresented: $showDayDetail) {
            if let selectedDate = selectedDay {
                DayDetailView(
                    date: selectedDate,
                    gad7Entry: gad7EntryForDate(selectedDate),
                    moodEntry: moodEntryForDate(selectedDate)
                )
            }
        }
    }
    
    private var monthYearString: String {
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: currentMonth)
    }
    
    private var daysInMonth: [Date] {
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
        let endOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.end ?? currentMonth
        
        var days: [Date] = []
        var currentDate = startOfMonth
        
        // Add days from previous month to fill the first week
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysToAdd = (firstWeekday - 1) % 7
        
        for i in 0..<daysToAdd {
            if let date = calendar.date(byAdding: .day, value: -daysToAdd + i, to: startOfMonth) {
                days.append(date)
            }
        }
        
        // Add days of current month
        while currentDate < endOfMonth {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return days
    }
    
    private func gad7EntryForDate(_ date: Date) -> GAD7Entry? {
        // Find all entries for this date and return the latest one
        let entriesForDate = gad7Entries.filter { entry in
            calendar.isDate(entry.date ?? Date.distantPast, inSameDayAs: date)
        }
        return entriesForDate.max { ($0.date ?? Date.distantPast) < ($1.date ?? Date.distantPast) }
    }
    
    private func moodEntryForDate(_ date: Date) -> MoodEntry? {
        moodEntries.first { entry in
            calendar.isDate(entry.date ?? Date.distantPast, inSameDayAs: date)
        }
    }
    
    private func previousMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func nextMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }
}

struct CalendarDayView: View {
    let date: Date
    let gad7Entry: GAD7Entry?
    let moodEntry: MoodEntry?
    let isCurrentMonth: Bool
    let isToday: Bool
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(.caption, design: .rounded))
                .fontWeight(isToday ? .bold : .medium)
                .foregroundColor(textColor)
            
            if let gad7Entry = gad7Entry {
                Circle()
                    .fill(dotColor(for: Int(gad7Entry.score)))
                    .frame(width: 6, height: 6)
            } else if moodEntry != nil {
                Circle()
                    .fill(Color.themeText.opacity(0.5))
                    .frame(width: 4, height: 4)
            }
        }
        .frame(height: 32)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isToday ? Color.themeDivider.opacity(0.5) : Color.clear)
        )
    }
    
    private var textColor: Color {
        if isToday {
            return .themeText
        } else if isCurrentMonth {
            return .themeText.opacity(0.8)
        } else {
            return .themeText.opacity(0.4)
        }
    }
    
    private func dotColor(for score: Int) -> Color {
        switch score {
        case 0...4:
            return Color.themeText.opacity(0.3)
        case 5...9:
            return Color.themeText.opacity(0.6)
        case 10...14:
            return Color.themeText
        default:
            return Color.themeCompanionOutline
        }
    }
}

struct DayDetailView: View {
    let date: Date
    let gad7Entry: GAD7Entry?
    let moodEntry: MoodEntry?
    
    @Environment(\.dismiss) private var dismiss
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.themeBackground
                    .ignoresSafeArea(.all)
                    .onAppear {
                        // Ensure background renders immediately
                    }

                VStack(spacing: 24) {
                    Text(dateFormatter.string(from: date))
                        .font(.system(.title2, design: .serif))
                        .fontWeight(.semibold)
                        .foregroundColor(.themeText)

                    if let gad7Entry = gad7Entry {
                        VStack(spacing: 12) {
                            Text("GAD-7 Score")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(.themeText)

                            Text("\(gad7Entry.score)/21")
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.themeText)

                            Text(getScoreCategory(Int(gad7Entry.score)))
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.themeText.opacity(0.7))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.themeCard)
                        )
                    }

                    if let moodEntry = moodEntry {
                        VStack(spacing: 12) {
                            Text("Mood")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(.themeText)

                            Text(moodEmoji(for: Int(moodEntry.moodValue)))
                                .font(.system(size: 48))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.themeCard)
                        )
                    }

                    if gad7Entry == nil && moodEntry == nil {
                        Text("No data for this day")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.themeText.opacity(0.6))
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.themeText)
                }
            }
        }
    }
    
    private func getScoreCategory(_ score: Int) -> String {
        switch score {
        case 0...4: return "Minimal Anxiety"
        case 5...9: return "Mild Anxiety"
        case 10...14: return "Moderate Anxiety"
        default: return "Severe Anxiety"
        }
    }
    
    private func moodEmoji(for mood: Int) -> String {
        let emojis = ["😔", "😕", "😐", "🙂", "😄"]
        return emojis[safe: mood] ?? "😐"
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var selectedDay: Date? = nil

        var body: some View {
            VStack {
                CalendarGridView(gad7Entries: [], moodEntries: [], selectedDay: $selectedDay)

                Spacer()
            }
            .padding()
            .background(Color.themeBackground)
        }
    }

    return PreviewWrapper()
}
