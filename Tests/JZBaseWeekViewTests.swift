//
//  JZBaseWeekViewTests.swift
//  JZCalendarWeekViewTests
//
//  Created by Jeff Zhang on 23/5/19.
//  Copyright © 2019 Jeff Zhang. All rights reserved.
//

import XCTest
@testable import JZCalendarWeekView

class JZBaseWeekViewTests: XCTestCase {

    private var baseWeekView: JZBaseWeekView!

    override func setUp() {
        super.setUp()
        baseWeekView = JZBaseWeekView.makeJZBaseWeekView()
    }

    override func tearDown() {
        // TODO: - Should set baseWeekView to nil after resolve async issue. Cause crash now in setup unowned self
        super.tearDown()
    }

    func testGetDateForSection_1Day() {
        let testDate = Helpers.testDate
        baseWeekView.setupCalendar(numOfDays: 1, setDate: testDate, allEvents: [:])

        let currentDate = baseWeekView.getDateForSection(1)
        XCTAssertEqual(currentDate, testDate)
        let firstDate = baseWeekView.getDateForSection(0)
        XCTAssertEqual(firstDate, testDate.add(component: .day, value: -1))
        let lastDate = baseWeekView.getDateForSection(2)
        XCTAssertEqual(lastDate, testDate.add(component: .day, value: 1))
    }

    func testGetDateForSection_3Days() {
        let testDate = Helpers.testDate
        baseWeekView.setupCalendar(numOfDays: 3, setDate: testDate, allEvents: [:])

        let currentDate = baseWeekView.getDateForSection(3)
        XCTAssertEqual(currentDate, testDate)
        let firstDate = baseWeekView.getDateForSection(0)
        XCTAssertEqual(firstDate, testDate.add(component: .day, value: -3))
        let lastDate = baseWeekView.getDateForSection(8)
        XCTAssertEqual(lastDate, testDate.add(component: .day, value: 5))
    }

    // 7 days will change the set Date depending on the firstDayOfWeek
    func testGetDateForSection_7Days() {
        // testeDate is 2019-05-23 Thursday, so first date of current page will be 2019-05-19 Sunday
        let testDate = Helpers.testDate
        baseWeekView.setupCalendar(numOfDays: 7, setDate: testDate, allEvents: [:], firstDayOfWeek: .Sunday)

        let currentDate = baseWeekView.getDateForSection(7 + 4)
        XCTAssertEqual(currentDate, testDate)
        let firstDate = baseWeekView.getDateForSection(0)
        XCTAssertEqual(firstDate, testDate.add(component: .day, value: -7 - 4))
        let lastDate = baseWeekView.getDateForSection(20)
        XCTAssertEqual(lastDate, testDate.add(component: .day, value: 9))
    }

    func testGetDateForContentOffsetX() {
        let testDate = Helpers.testDate
        baseWeekView.setupCalendar(numOfDays: 3, setDate: testDate, allEvents: [:])
        var contentOffsetX: CGFloat

        contentOffsetX = 0
        let firstDate = baseWeekView.getDateForContentOffsetX(contentOffsetX)
        XCTAssertEqual(firstDate, testDate.add(component: .day, value: -3))

        contentOffsetX = baseWeekView.flowLayout.sectionWidth * 3
        let currentDate = baseWeekView.getDateForContentOffsetX(contentOffsetX)
        XCTAssertEqual(currentDate, testDate)

        contentOffsetX = baseWeekView.flowLayout.sectionWidth * 3 - 1
        let previousDate = baseWeekView.getDateForContentOffsetX(contentOffsetX)
        XCTAssertEqual(previousDate, testDate.add(component: .day, value: -1))

        // TODO: - Add test case for contentsMargin with horizontal value, currently contentsMargin is getter
    }

    func testGetDateForContentOffsetY() {
        var contentOffsetY: CGFloat

        // default contentsMargin top is 10
        contentOffsetY = 0
        let startTimeBefore0 = baseWeekView.getDateForContentOffsetY(contentOffsetY)
        XCTAssertTrue(startTimeBefore0 == (0, 0))

        contentOffsetY = baseWeekView.flowLayout.contentsMargin.top + 1
        let startTime = baseWeekView.getDateForContentOffsetY(contentOffsetY)
        XCTAssertTrue(startTime == (0, 1))

        contentOffsetY = baseWeekView.flowLayout.hourHeight * 1.5 + baseWeekView.flowLayout.contentsMargin.top
        let time1Hour30Mins = baseWeekView.getDateForContentOffsetY(contentOffsetY)
        XCTAssertTrue(time1Hour30Mins == (1, 30))
    }

    func testGetDateForContentOffset() {
        let testDate = Helpers.testDate
        baseWeekView.setupCalendar(numOfDays: 3, setDate: testDate, allEvents: [:])
        let contentOffset = CGPoint(x: baseWeekView.flowLayout.sectionWidth * 3, y: baseWeekView.flowLayout.hourHeight * 1.5 + baseWeekView.flowLayout.contentsMargin.top)
        XCTAssertEqual(baseWeekView.getDateForContentOffset(contentOffset), Date().set(year: 2019, month: 5, day: 23, hour: 1, minute: 30, second: 0))
    }

    func testGetDateForPointX() {
        let testDate = Helpers.testDate
        baseWeekView.setupCalendar(numOfDays: 3, setDate: testDate, allEvents: [:])
        var pointX: CGFloat

        pointX = baseWeekView.flowLayout.sectionWidth * 3 + baseWeekView.flowLayout.rowHeaderWidth
        let currentDate = baseWeekView.getDateForPointX(pointX)
        XCTAssertEqual(currentDate, testDate)

        pointX = baseWeekView.flowLayout.sectionWidth * 3 + baseWeekView.flowLayout.rowHeaderWidth - 1
        let previousDate = baseWeekView.getDateForPointX(pointX)
        XCTAssertEqual(previousDate, testDate.add(component: .day, value: -1))

        // TODO: - Add test case for contentsMargin with horizontal value, currently contentsMargin is getter
    }

    func testGetDateForPointY() {
        var pointY: CGFloat
        let baseY = baseWeekView.flowLayout.contentsMargin.top + baseWeekView.flowLayout.columnHeaderHeight + baseWeekView.flowLayout.allDayHeaderHeight
        // should set contentSize height, otherwise getDateForPointY cannot work properly
        baseWeekView.collectionView.contentSize.height = baseY + baseWeekView.flowLayout.hourHeight * 24 + baseWeekView.flowLayout.contentsMargin.bottom

        // default contentsMargin top is 10
        pointY = baseY
        let startTimeBefore0 = baseWeekView.getDateForPointY(pointY)
        XCTAssertTrue(startTimeBefore0 == (0, 0))

        pointY = baseY + 1
        let startTime = baseWeekView.getDateForPointY(pointY)
        XCTAssertTrue(startTime == (0, 1))

        pointY = baseY + baseWeekView.flowLayout.hourHeight * 1.5
        let time1Hour30Mins = baseWeekView.getDateForPointY(pointY)
        XCTAssertTrue(time1Hour30Mins == (1, 30))

        // maxY - 0.5 (1 will be rounded to 58 mins)
        pointY = baseY + baseWeekView.flowLayout.hourHeight * 24 - 0.5
        let endTime = baseWeekView.getDateForPointY(pointY)
        XCTAssertTrue(endTime == (23, 59))

        // maxY + 1
        pointY = baseY + baseWeekView.flowLayout.hourHeight * 24 + 1
        let endTimeOver24 = baseWeekView.getDateForPointY(pointY)
        XCTAssertTrue(endTimeOver24 == (24, 00))
    }

    func testGetDateForPoint() {
        let testDate = Helpers.testDate
        baseWeekView.setupCalendar(numOfDays: 3, setDate: testDate, allEvents: [:])
        let baseY = baseWeekView.flowLayout.contentsMargin.top + baseWeekView.flowLayout.columnHeaderHeight + baseWeekView.flowLayout.allDayHeaderHeight
        baseWeekView.collectionView.contentSize.height = baseY + baseWeekView.flowLayout.hourHeight * 24 + baseWeekView.flowLayout.contentsMargin.bottom

        let point = CGPoint(x: baseWeekView.flowLayout.sectionWidth * 3 + baseWeekView.flowLayout.rowHeaderWidth,
                            y: baseY + baseWeekView.flowLayout.hourHeight * 1.5)
        XCTAssertEqual(baseWeekView.getDateForPoint(point), Date().set(year: 2019, month: 5, day: 23, hour: 1, minute: 30, second: 0))
    }

    func testSetHorizontalEdgesOffsetX() {

        func days(_ start: Date, _ end: Date) -> CGFloat { return CGFloat(Date.daysBetween(start: start, end: end, ignoreHours: true)) }

        let testDates = [
            nil,
            Helpers.getShortDate("2018-02-15"), // initDate - 1
            Helpers.getShortDate("2018-02-16"), // initDate
            Helpers.getShortDate("2018-02-17"), // initDate + 1
            Helpers.getShortDate("2018-02-18"), // initDate + 2
            Helpers.getShortDate("2018-02-19"), // currentPageFirstDate
            Helpers.getShortDate("2018-02-20"), // currentPageFirstDate + 1
            Helpers.getShortDate("2018-02-21"), // currentPageLastDate
            Helpers.getShortDate("2018-02-22"), // currentPageLastDate + 1
            Helpers.getShortDate("2018-02-23"), // currentPageLastDate + 2
            Helpers.getShortDate("2018-02-24"), // lastDate
            Helpers.getShortDate("2018-02-25"), // lastDate + 1
            nil
        ]

        let currentPageFirstDate = testDates[5]!
        let currentPageLastDate = testDates[7]!
        let initDate = testDates[2]!
        let lastDate = testDates[10]!

        let sectionWidth = baseWeekView.flowLayout.sectionWidth!

        // Assume startDate should be eariler than endDate
        func testbaseWeekView() {
            for i in 0..<testDates.count {
                for j in i..<testDates.count {
                    let startDate = testDates[i], endDate = testDates[j]
                    let scrollableRange = (startDate, endDate)
                    baseWeekView.scrollableRange = scrollableRange

                    if let startDate = startDate, let endDate = endDate {
                        // out of range
                        if startDate > currentPageLastDate || endDate < currentPageFirstDate {
                            XCTAssertEqual(baseWeekView.scrollableEdges.leftX, baseWeekView.contentViewWidth, "\(scrollableRange)")
                            XCTAssertEqual(baseWeekView.scrollableEdges.rightX, baseWeekView.contentViewWidth, "\(scrollableRange)")
                            continue
                        }

                        // startDate in valid range
                        if case currentPageFirstDate...currentPageLastDate = startDate {
                            XCTAssertEqual(baseWeekView.scrollableEdges.leftX, baseWeekView.contentViewWidth, "\(startDate)")
                        } else {
                            // startDate < currentPageFirstDate
                            if baseWeekView.scrollType == .pageScroll {
                                XCTAssertNil(baseWeekView.scrollableEdges.leftX, "\(startDate)")
                            } else {
                                if startDate > initDate {
                                    XCTAssertEqual(baseWeekView.scrollableEdges.leftX, days(initDate, startDate) * sectionWidth, "\(startDate)")
                                } else {
                                    XCTAssertNil(baseWeekView.scrollableEdges.leftX, "\(startDate)")
                                }
                            }
                        }

                        // endDate in valid range
                        if case currentPageFirstDate...currentPageLastDate = endDate {
                            XCTAssertEqual(baseWeekView.scrollableEdges.rightX, baseWeekView.contentViewWidth, "\(endDate)")
                        } else {
                            // endDate > currentPageLastDate
                            if baseWeekView.scrollType == .pageScroll {
                                XCTAssertNil(baseWeekView.scrollableEdges.rightX, "\(endDate)")
                            } else {
                                if endDate < lastDate {
                                    XCTAssertEqual(baseWeekView.scrollableEdges.rightX, (days(initDate, endDate) - CGFloat(baseWeekView.numOfDays) + 1) * sectionWidth, "\(endDate)")
                                } else {
                                    XCTAssertNil(baseWeekView.scrollableEdges.rightX, "\(endDate)")
                                }
                            }
                        }
                        continue
                    }

                    if let startDate = startDate {
                        // out of range
                        if startDate > currentPageLastDate {
                            XCTAssertEqual(baseWeekView.scrollableEdges.leftX, baseWeekView.contentViewWidth, "\(scrollableRange)")
                            XCTAssertEqual(baseWeekView.scrollableEdges.rightX, baseWeekView.contentViewWidth, "\(scrollableRange)")
                        } else if startDate >= currentPageFirstDate {
                            XCTAssertEqual(baseWeekView.scrollableEdges.leftX, baseWeekView.contentViewWidth, "\(scrollableRange)")
                            XCTAssertNil(baseWeekView.scrollableEdges.rightX, "nil")
                        } else {
                            if baseWeekView.scrollType == .pageScroll {
                                XCTAssertNil(baseWeekView.scrollableEdges.leftX, "nil")
                            } else {
                                if startDate > initDate {
                                    XCTAssertEqual(baseWeekView.scrollableEdges.leftX, days(initDate, startDate) * sectionWidth, "\(startDate)")
                                } else {
                                    XCTAssertNil(baseWeekView.scrollableEdges.leftX, "\(startDate)")
                                }
                            }
                            XCTAssertNil(baseWeekView.scrollableEdges.rightX, "nil")
                        }
                        continue
                    }

                    if let endDate = endDate {
                        // out of range
                        if endDate < currentPageFirstDate {
                            XCTAssertEqual(baseWeekView.scrollableEdges.leftX, baseWeekView.contentViewWidth, "\(scrollableRange)")
                            XCTAssertEqual(baseWeekView.scrollableEdges.rightX, baseWeekView.contentViewWidth, "\(scrollableRange)")
                        } else if endDate <= currentPageLastDate {
                            XCTAssertNil(baseWeekView.scrollableEdges.leftX, "nil")
                            XCTAssertEqual(baseWeekView.scrollableEdges.rightX, baseWeekView.contentViewWidth, "\(scrollableRange)")
                        } else {
                            XCTAssertNil(baseWeekView.scrollableEdges.leftX, "nil")
                            if baseWeekView.scrollType == .pageScroll {
                                XCTAssertNil(baseWeekView.scrollableEdges.rightX, "nil")
                            } else {
                                if endDate < lastDate {
                                    XCTAssertEqual(baseWeekView.scrollableEdges.rightX, (days(initDate, endDate) - CGFloat(baseWeekView.numOfDays) + 1) * sectionWidth, "\(endDate)")
                                } else {
                                    XCTAssertNil(baseWeekView.scrollableEdges.rightX, "\(endDate)")
                                }
                            }
                        }
                        continue
                    }
                    XCTAssertNil(baseWeekView.scrollableEdges.leftX, "start nil")
                    XCTAssertNil(baseWeekView.scrollableEdges.rightX, "end nil")
                }
            }
        }
        baseWeekView.setupCalendar(numOfDays: 3, setDate: Helpers.getShortDate("2018-02-19"), allEvents: [:], scrollType: .pageScroll, scrollableRange: (nil, nil))
        testbaseWeekView()
        baseWeekView.scrollType = .sectionScroll
        baseWeekView.setHorizontalEdgesOffsetX()
        testbaseWeekView()
    }

}
