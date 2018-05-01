//
//  JZWeekViewHelper.swift
//  JZCalendarWeekView
//
//  Created by Jeff Zhang on 28/3/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

public enum JZSupplementaryViewKinds {
    public static let columnHeader = JZColumnHeader.className
    public static let rowHeader = JZRowHeader.className
    public static let cornerHeader = JZCornerHeader.className
    public static let baseEventCell = JZBaseEventCell.className
}

public enum JZDecorationViewKinds {
    public static let columnHeaderBackground = JZColumnHeaderBackground.className
    public static let rowHeaderBackground = JZRowHeaderBackground.className
    public static let cornerHeaderBackground = JZCornerHeaderBackground.className
    public static let verticalGridline = "VerticalGridline"
    public static let horizontalGridline = "HorizontalGridline"
    public static let currentTimeGridline = JZCurrentTimeIndicator.className
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

public enum JZHourGridDivision: Int {
    case noneDiv = 0
    case minutes_5 = 5
    case minutes_10 = 10
    case minutes_15 = 15
    case minutes_20 = 20
    case minutes_30 = 30
}

public enum DayOfWeek: Int {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
}

public enum JZScrollType {
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
        var resultEvents = [Date: [T]]()
        for event in originalEvents {
            let startDateStartDay = event.startDate.startOfDay
            // get days from both startOfDay, otherwise 22:00 - 01:00 case will get 0 daysBetween result
            let daysBetween = Date.daysBetween(start: startDateStartDay, end: event.endDate, ignoreHours: true)
            if daysBetween == 0 {
                if resultEvents[startDateStartDay] == nil {
                    resultEvents[startDateStartDay] = [T]()
                }
                let copiedEvent = event.copy() as! T
                resultEvents[startDateStartDay]!.append(copiedEvent)
            } else {
                // Crossing day
                for day in 0...daysBetween {
                    let currentStartDate = startDateStartDay.add(component: .day, value: day)
                    if resultEvents[currentStartDate] == nil {
                        resultEvents[currentStartDate] = [T]()
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
                    resultEvents[currentStartDate]!.append(newEvent)
                }
            }
        }
        return resultEvents
    }
}
