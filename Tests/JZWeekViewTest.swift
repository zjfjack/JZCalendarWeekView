//
//  JZWeekViewTest.swift
//  JZCalendarWeekViewTests
//
//  Created by Jeff Zhang on 29/3/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import XCTest
@testable import JZCalendarWeekView

class JZWeekViewTest: XCTestCase {
    
    var longPressView = JZLongPressWeekView(frame: .zero)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetLongPressStartTime() {
        let timeMinInterval = 15
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm"
        let dateInSection = dateFormatter.date(from: "2018-02-22 00:00")!
        let testDate1 = dateFormatter.date(from: "2018-02-21 23:51")!
        let testDate2 = dateFormatter.date(from: "2018-02-23 00:12")!
        let testDate3 = dateFormatter.date(from: "2018-02-22 22:14")!
        let testDate4 = dateFormatter.date(from: "2018-02-22 22:25")!
        let answer1 = longPressView.getLongPressStartDate(date: testDate1, dateInSection: dateInSection, timeMinInterval: timeMinInterval)
        let answer2 = longPressView.getLongPressStartDate(date: testDate2, dateInSection: dateInSection, timeMinInterval: timeMinInterval)
        let answer3 = longPressView.getLongPressStartDate(date: testDate3, dateInSection: dateInSection, timeMinInterval: timeMinInterval)
        let answer4 = longPressView.getLongPressStartDate(date: testDate4, dateInSection: dateInSection, timeMinInterval: timeMinInterval)
        XCTAssertEqual(answer1, dateFormatter.date(from: "2018-02-22 00:00")!, "yesterday should set as start of current day")
        XCTAssertEqual(answer2, dateFormatter.date(from: "2018-02-23 00:00")!, "the nex day should set as start of the next day")
        XCTAssertEqual(answer3, dateFormatter.date(from: "2018-02-22 22:00")!, "(0,14) => 0")
        XCTAssertEqual(answer4, dateFormatter.date(from: "2018-02-22 22:15")!, "(15,29)) => 15")
    }
    
    func testGetDateForSection() {
        let today = Date().startOfDay
        let calendar = Calendar.current
        // 7 days will change the set Date depending on the firstDayOfWeek
        [1, 3, 10].forEach {
            longPressView.setupCalendar(numOfDays: $0, setDate: today, allEvents: [:])
            let currentDate = longPressView.getDateForSection(longPressView.numOfDays)
            XCTAssertEqual(currentDate, today)
            let firstDate = longPressView.getDateForSection(0)
            XCTAssertEqual(firstDate, calendar.date(byAdding: .day, value: -longPressView.numOfDays, to: today))
            let lastDate = longPressView.getDateForSection(longPressView.numOfDays*3 - 1)
            XCTAssertEqual(lastDate, calendar.date(byAdding: .day, value: longPressView.numOfDays*2 - 1, to: today))
        }
    }
}
