//
//  Helpers.swift
//  JZCalendarWeekViewTests
//
//  Created by Jeff Zhang on 23/5/19.
//  Copyright © 2019 Jeff Zhang. All rights reserved.
//

import JZCalendarWeekView
import UIKit

extension JZBaseWeekView {

    static func makeJZBaseWeekView() -> JZBaseWeekView {
        let weekView = JZBaseWeekView(frame: Constants.weekViewFrame)
        weekView.flowLayout.sectionWidth = Constants.weekViewSectionWidth
        return weekView
    }
}

extension JZLongPressWeekView {

    static func makeJZLongPressWeekView() -> JZLongPressWeekView {
        let weekView = JZLongPressWeekView(frame: Constants.weekViewFrame)
        weekView.flowLayout.sectionWidth = Constants.weekViewSectionWidth
        return weekView
    }

}

struct Helpers {

    private static let longDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        return dateFormatter
    }()

    private static let shortDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter
    }()

    static let testDate: Date = getLongDate("2019-05-23 00:00:00")

    static func getLongDate(_ dateStr: String) -> Date {
        return longDateFormatter.date(from: dateStr)!
    }

    static func getShortDate(_ dateStr: String) -> Date {
        return shortDateFormatter.date(from: dateStr)!
    }

}
