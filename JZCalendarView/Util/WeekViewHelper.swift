//
//  WeekViewHelper.swift
//  JZCalendarView
//
//  Created by Jeff Zhang on 28/3/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import Foundation

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
    static let currentTimeGridline = BaseCurrentTimeIndicator.className
}

enum HourGridDivision: Int {
    case noneDiv = 0
    case minutes_5 = 5
    case minutes_10 = 10
    case minutes_15 = 15
    case minutes_20 = 20
    case minutes_30 = 30
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

public enum DayOfWeek: Int {
    /// Days of the week.
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
}

open class WeekViewHelper {
    
    
    
    
}

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}
