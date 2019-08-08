//
//  JZLongPressWeekViewTest.swift
//  JZCalendarWeekViewTests
//
//  Created by Jeff Zhang on 29/3/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import XCTest
@testable import JZCalendarWeekView

class JZLongPressWeekViewTests: XCTestCase {
    
    private var longPressView: JZLongPressWeekView!
    
    override func setUp() {
        super.setUp()
        longPressView = JZLongPressWeekView.makeJZLongPressWeekView()
    }
    
    override func tearDown() {
        // TODO: - Should set longPressView to nil after resolve async issue. Cause crash now in setup unowned self
        super.tearDown()
    }
    
    func testGetLongPressStartTime() {
        let timeMinInterval = 15
        let dateInSection = Helpers.getLongDate("2018-02-22 00:00:00")
        let testDate1 = Helpers.getLongDate("2018-02-21 23:51:00")
        let testDate2 = Helpers.getLongDate("2018-02-23 00:12:00")
        let testDate3 = Helpers.getLongDate("2018-02-22 22:14:00")
        let testDate4 = Helpers.getLongDate("2018-02-22 22:25:00")
        let answer1 = longPressView.getLongPressStartDate(date: testDate1, dateInSection: dateInSection, timeMinInterval: timeMinInterval)
        let answer2 = longPressView.getLongPressStartDate(date: testDate2, dateInSection: dateInSection, timeMinInterval: timeMinInterval)
        let answer3 = longPressView.getLongPressStartDate(date: testDate3, dateInSection: dateInSection, timeMinInterval: timeMinInterval)
        let answer4 = longPressView.getLongPressStartDate(date: testDate4, dateInSection: dateInSection, timeMinInterval: timeMinInterval)
        XCTAssertEqual(answer1, Helpers.getLongDate("2018-02-22 00:00:00"), "yesterday should set as start of current day")
        XCTAssertEqual(answer2, Helpers.getLongDate("2018-02-23 00:00:00"), "the nex day should set as start of the next day")
        XCTAssertEqual(answer3, Helpers.getLongDate("2018-02-22 22:00:00"), "(0,14) => 0")
        XCTAssertEqual(answer4, Helpers.getLongDate("2018-02-22 22:15:00"), "(15,29)) => 15")
    }
    
    // Only test xSelfView in this method, xCollectionView is already tested in JZBaseWeekViewTests
    func testGetDateForPointX() {
        let testDate = Helpers.testDate
        longPressView.setupCalendar(numOfDays: 3, setDate: testDate, allEvents: [:])
        let xCollectionView: CGFloat = longPressView.flowLayout.sectionWidth * 3 + longPressView.flowLayout.rowHeaderWidth
        var xSelfView: CGFloat
        
        // xSelfView > longPressLeftMarginX && xSelfView < longPressRightMarginX
        xSelfView = longPressView.longPressLeftMarginX + 1
        let currentDate = longPressView.getDateForPointX(xCollectionView: xCollectionView, xSelfView: xSelfView)
        XCTAssertEqual(currentDate, testDate)
        
        // xSelfView < longPressLeftMarginX
        xSelfView = longPressView.longPressLeftMarginX - 1
        let previousDate = longPressView.getDateForPointX(xCollectionView: xCollectionView, xSelfView: xSelfView)
        XCTAssertEqual(previousDate, longPressView.getDateForPointX(xCollectionView).add(component: .day, value: 1))
        
        // xSelfView > longPressRightMarginX
        xSelfView = longPressView.frame.width + 1
        let nextDate = longPressView.getDateForPointX(xCollectionView: xCollectionView, xSelfView: xSelfView)
        XCTAssertEqual(nextDate, longPressView.getDateForPointX(xCollectionView).add(component: .day, value: -1))
        
        // Skip isScrolling test because it is private
    }
    
    func testGetDateForPoint() {
        let testDate = Helpers.testDate
        longPressView.setupCalendar(numOfDays: 3, setDate: testDate, allEvents: [:])
        let baseY = longPressView.flowLayout.contentsMargin.top + longPressView.flowLayout.columnHeaderHeight + longPressView.flowLayout.allDayHeaderHeight
        longPressView.collectionView.contentSize.height = baseY + longPressView.flowLayout.hourHeight * 24 + longPressView.flowLayout.contentsMargin.bottom
        
        let pointCollectionView = CGPoint(x: longPressView.flowLayout.sectionWidth * 3 + longPressView.flowLayout.rowHeaderWidth,
                                          y: baseY + longPressView.flowLayout.hourHeight * 1.5)
        let pointSelfView = CGPoint(x: longPressView.longPressLeftMarginX - 1, y: 0)
        XCTAssertEqual(longPressView.getDateForPoint(pointCollectionView: pointCollectionView, pointSelfView: pointSelfView),
                       Date().set(year: 2019, month: 5, day: 23, hour: 1, minute: 30, second: 0).add(component: .day, value: 1))
    }
}
