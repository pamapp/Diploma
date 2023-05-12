//
//  Date+Extensions.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 19.02.2023.
//

import Foundation

extension Date {
    
    // MARK: Formatting the date into the desired string format
    
    func getFormattedDateString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: self).capitalized 
    }
}

extension Date {
    
    // MARK: Date comparison
    
    var isToday: Bool { Calendar.current.isDateInToday(self) }
    var isThisYear: Bool { self.year == Date().year }
    var year: Int { Calendar.current.dateComponents([.year], from: self).year! }
    
    func isCurrentMinute(_ date: Date = Date()) -> Bool {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .minute], from: date)
        let selfComponents = calendar.dateComponents([.year, .month, .day, .minute], from: self)
        return calendar.date(from: selfComponents)! == calendar.date(from: dateComponents)!
    }
    
    func getDaysNum(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: self), to: Calendar.current.startOfDay(for: date)).day ?? 0
    }
}
