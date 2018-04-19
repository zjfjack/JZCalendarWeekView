//
//  DateExtension.swift
//  JZCalendarWeekView
//
//  Created by Jeff Zhang on 28/3/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import Foundation

extension Date {
    
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    var isYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    var isTomorrow: Bool {
        return Calendar.current.isDateInTomorrow(self)
    }
    
    func add(component: Calendar.Component, value: Int) -> Date {
        return Calendar.current.date(byAdding: component, value: value, to: self)!
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        return Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self)!
    }
    
    func getDayOfWeek() -> DayOfWeek {
        let weekDayNum = Calendar.current.component(.weekday, from: self)
        let weekDay = DayOfWeek(rawValue: weekDayNum)!
        return weekDay
    }
    
    func getTimeIgnoreSecondsFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    static func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: start, to: end).day!
    }
}
