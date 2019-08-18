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
    public static let allDayHeader = JZAllDayHeader.className
    public static let eventCell = "eventCell"
    public static let currentTimeline = "currentTimeline"
}

public enum JZDecorationViewKinds {
    public static let columnHeaderBackground = JZColumnHeaderBackground.className
    public static let rowHeaderBackground = JZRowHeaderBackground.className
    public static let allDayHeaderBackground = JZAllDayHeaderBackground.className
    public static let allDayCorner = JZAllDayCorner.className
    public static let verticalGridline = "VerticalGridline"
    public static let horizontalGridline = "HorizontalGridline"
}

/// For checking scrollView(collectionView) currently scrolling direction
struct ScrollDirection {

    enum Direction {
        case horizontal
        case vertical
    }

    /// scrolling direction
    let direction: Direction
    /// locked at curtain x or y value, nil means not locked, similar to previous initialContentOffset but put it in direction
    let lockedAt: CGFloat?

    init(direction: Direction, lockedAt: CGFloat?) {
        self.direction = direction
        self.lockedAt = lockedAt
    }
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
    case Sunday = 1, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
}

public enum JZScrollType {
    case pageScroll
    case sectionScroll
    //TODO: - infiniteScroll
}

public enum JZCurrentTimelineType {
    case section // Display the current time line only in today's section
    case page // Display the current time line in the whole page including today
}

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
                if let copiedEvent = event.copy() as? T {
                    resultEvents[startDateStartDay]?.append(copiedEvent)
                }
            } else {
                // Cross days
                for day in 0...daysBetween {
                    let currentStartDate = startDateStartDay.add(component: .day, value: day)
                    if resultEvents[currentStartDate] == nil {
                        resultEvents[currentStartDate] = [T]()
                    }
                    guard let newEvent = event.copy() as? T else { return resultEvents }
                    if day == 0 {
                        newEvent.intraEndDate = startDateStartDay.endOfDay
                    } else if day == daysBetween {
                        newEvent.intraStartDate = currentStartDate
                    } else {
                        newEvent.intraStartDate = currentStartDate.startOfDay
                        newEvent.intraEndDate = currentStartDate.endOfDay
                    }
                    resultEvents[currentStartDate]?.append(newEvent)
                }
            }
        }
        return resultEvents
    }

    // This function has to be updated once new devices coming
    private static var hasNotch: Bool = {
        switch UIScreen.main.nativeBounds.height {
        case 2436: // iPhone X / iPhone XS
            fallthrough
        case 2688: // iPhone Xs Max
            fallthrough
        case 1792: // iPhone XR
            return true
        default:
            return false
        }
    }()

    /// Handle the viewWillTransition in UIViewController, only need call this function in ViewController owning JZWeekView.
    ///
    /// Support All orientations (including iPhone X Landscape) and iPad (Slide Over and Split View)
    /// - Parameters:
    ///   - size: viewWillTransition to size
    ///   - weekView: the JZWeekView
    open class func viewTransitionHandler(to size: CGSize, weekView: JZBaseWeekView, needRefresh: Bool = true) {
        if hasNotch {
            let flowLayout = weekView.flowLayout!
            // Not differentiate the left and right because of willTransition cannot get the following UIDeviceOrientation
            let isLandscape = size.width > size.height
            flowLayout.rowHeaderWidth = isLandscape ? flowLayout.defaultRowHeaderWidth + CGFloat(32) : flowLayout.defaultRowHeaderWidth
        }
        if needRefresh {
            weekView.refreshWeekView()
        }
    }
}
