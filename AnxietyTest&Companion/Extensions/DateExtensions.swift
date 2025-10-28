//
//  DateExtensions.swift
//  AnxietyTest&Companion
//
//  Created by Mehmet Ali Kısacık on 26.10.2025.
//

import Foundation

extension Date {
    /// Returns the start of the day for this date
    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// Returns the number of days between this date and another date
    func daysAgo(from date: Date) -> Int {
        Calendar.current.dateComponents([.day], from: self, to: date).day ?? 0
    }
    
    /// Returns true if this date is the same day as another date
    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    /// Returns a formatted string for display (e.g., "Oct 25")
    func shortFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }
    
    /// Returns a formatted string for display (e.g., "October 25, 2024")
    func longFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: self)
    }
    
    /// Returns the first day of the month for this date
    func firstDayOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    /// Returns the last day of the month for this date
    func lastDayOfMonth() -> Date {
        let calendar = Calendar.current
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: self.firstDayOfMonth()) ?? self
        return calendar.date(byAdding: .day, value: -1, to: nextMonth) ?? self
    }
    
    /// Returns an array of dates for the current month
    func daysInMonth() -> [Date] {
        let calendar = Calendar.current
        let firstDay = self.firstDayOfMonth()
        let lastDay = self.lastDayOfMonth()
        
        var dates: [Date] = []
        var currentDate = firstDay
        
        while currentDate <= lastDay {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return dates
    }
}
