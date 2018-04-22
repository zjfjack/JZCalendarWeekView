//
//  JZWeekViewHelper.swift
//  JZCalendarWeekView
//
//  Created by Jeff Zhang on 28/3/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

enum SupplementaryViewKinds {
    static let columnHeader = ColumnHeader.className
    static let rowHeader = RowHeader.className
    static let cornerHeader = CornerHeader.className
    static let baseEventCell = BaseEventCell.className
}

enum DecorationViewKinds {
    static let columnHeaderBackground = ColumnHeaderBackground.className
    static let rowHeaderBackground = RowHeaderBackground.className
    static let cornerHeaderBackground = CornerHeaderBackground.className
    static let verticalGridline = "VerticalGridline"
    static let horizontalGridline = "HorizontalGridline"
    static let currentTimeGridline = CurrentTimeIndicator.className
}

enum ScrollDirection {
    case none
    case crazy
    case left
    case right
    case up
    case down
    case horizontal
    case vertical
}

public enum HourGridDivision: Int {
    case noneDiv = 0
    case minutes_5 = 5
    case minutes_10 = 10
    case minutes_15 = 15
    case minutes_20 = 20
    case minutes_30 = 30
}

public enum DayOfWeek: Int {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    
    public func getDayName() -> String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
    
    public static func getDayOfWeekList() -> [DayOfWeek] {
        return [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
    }
}

public enum CalendarViewScrollType: String {
    case pageScroll
    case sectionScroll
    //TODO: - infiniteScroll
}

public typealias EventsByDate = [Date:[JZBaseEvent]]

open class JZWeekViewHelper {
    
    /**
     Get calculated events dictionary with intraStartTime and intraEndTime
     - Parameters:
        - originalEvents: A list of original Events (subclassed from BaseEvent)
     - Returns:
        A dictionary used by JZBaseWeekView. Key is a day Date, value is all the events in that day
     */
    open class func getIntraEventsByDate<T: JZBaseEvent>(originalEvents: [T]) -> [Date: [T]] {
        var treatedEvents = [Date: [T]]()
        for event in originalEvents {
            let startDateStartDay = event.startDate.startOfDay
            let daysBetween = Date.daysBetween(start: event.startDate, end: event.endDate)
            if daysBetween == 0 {
                if treatedEvents[startDateStartDay] == nil {
                    treatedEvents[startDateStartDay] = [T]()
                }
                let copiedEvent = event.copy() as! T
                treatedEvents[startDateStartDay]!.append(copiedEvent)
            } else {
                // Crossing day
                for day in 0...daysBetween {
                    let currentStartDate = startDateStartDay.add(component: .day, value: day)
                    if treatedEvents[currentStartDate] == nil {
                        treatedEvents[currentStartDate] = [T]()
                    }
                    let newEvent = event.copy() as! T
                    if day == 0 {
                        newEvent.intraEndDate = startDateStartDay.endOfDay
                    } else if day == daysBetween {
                        newEvent.intraStartDate = currentStartDate
                    } else {
                        newEvent.intraStartDate = currentStartDate.startOfDay
                        newEvent.intraEndDate = currentStartDate.endOfDay
                    }
                    treatedEvents[currentStartDate]!.append(newEvent)
                }
            }
        }
        return treatedEvents
    }
}
