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
    
    var longPressView: JZLongPressWeekView!
    
    override func setUp() {
        super.setUp()
        
        longPressView = JZLongPressWeekView(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        longPressView.flowLayout.sectionWidth = 111
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
    
    
    func testSetHorizontalEdgesOffsetX() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        
        func date(_ str: String) -> Date { return dateFormatter.date(from: str)! }
        func days(_ start: Date, _ end: Date) -> CGFloat { return CGFloat(Date.daysBetween(start: start, end: end, ignoreHours: true)) }
        
        let testDates = [nil,
                         date("2018-02-15"), // initDate - 1
                         date("2018-02-16"), // initDate
                         date("2018-02-17"), // initDate + 1
                         date("2018-02-18"), // initDate + 2
                         date("2018-02-19"), // currentPageFirstDate
                         date("2018-02-20"), // currentPageFirstDate + 1
                         date("2018-02-21"), // currentPageLastDate
                         date("2018-02-22"), // currentPageLastDate + 1
                         date("2018-02-23"), // currentPageLastDate + 2
                         date("2018-02-24"), // lastDate
                         date("2018-02-25"), // lastDate + 1
                         nil]
        
        let currentPageFirstDate = testDates[5]!
        let currentPageLastDate = testDates[7]!
        let initDate = testDates[2]!
        let lastDate = testDates[10]!
        
        let sectionWidth = longPressView.flowLayout.sectionWidth!
        
        // Assume startDate should be eariler than endDate
        func testLongPressView() {
            for i in 0..<testDates.count {
                for j in i..<testDates.count {
                    let startDate = testDates[i], endDate = testDates[j]
                    let scrollableRange = (startDate, endDate)
                    longPressView.scrollableRange = scrollableRange
                    
                    if let startDate = startDate, let endDate = endDate {
                        // out of range
                        if startDate > currentPageLastDate || endDate < currentPageFirstDate {
                            XCTAssertEqual(longPressView.scrollableEdges.leftX, longPressView.contentViewWidth, "\(startDate, endDate)")
                            XCTAssertEqual(longPressView.scrollableEdges.rightX, longPressView.contentViewWidth, "\(startDate, endDate)")
                            continue
                        }
                        
                        // startDate in valid range
                        if case currentPageFirstDate...currentPageLastDate = startDate {
                            XCTAssertEqual(longPressView.scrollableEdges.leftX, longPressView.contentViewWidth, "\(startDate)")
                        } else {
                            // startDate < currentPageFirstDate
                            if longPressView.scrollType == .pageScroll {
                                XCTAssertNil(longPressView.scrollableEdges.leftX, "\(startDate)")
                            } else {
                                if startDate > initDate {
                                    XCTAssertEqual(longPressView.scrollableEdges.leftX, days(initDate, startDate) * sectionWidth, "\(startDate)")
                                } else {
                                    XCTAssertNil(longPressView.scrollableEdges.leftX, "\(startDate)")
                                }
                            }
                        }
                        
                        // endDate in valid range
                        if case currentPageFirstDate...currentPageLastDate = endDate {
                            XCTAssertEqual(longPressView.scrollableEdges.rightX, longPressView.contentViewWidth, "\(endDate)")
                        } else {
                            // endDate > currentPageLastDate
                            if longPressView.scrollType == .pageScroll {
                                XCTAssertNil(longPressView.scrollableEdges.rightX, "\(endDate)")
                            } else {
                                if endDate < lastDate {
                                    XCTAssertEqual(longPressView.scrollableEdges.rightX, (days(initDate, endDate) - CGFloat(longPressView.numOfDays) + 1) * sectionWidth, "\(endDate)")
                                } else {
                                    XCTAssertNil(longPressView.scrollableEdges.rightX, "\(endDate)")
                                }
                            }
                        }
                        continue
                    }
                    
                    if let startDate = startDate {
                        // out of range
                        if startDate > currentPageLastDate {
                            XCTAssertEqual(longPressView.scrollableEdges.leftX, longPressView.contentViewWidth, "\(startDate, endDate)")
                            XCTAssertEqual(longPressView.scrollableEdges.rightX, longPressView.contentViewWidth, "\(startDate, endDate)")
                        } else if startDate >= currentPageFirstDate {
                            XCTAssertEqual(longPressView.scrollableEdges.leftX, longPressView.contentViewWidth, "\(startDate, endDate)")
                            XCTAssertNil(longPressView.scrollableEdges.rightX, "nil")
                        } else {
                            if longPressView.scrollType == .pageScroll {
                                XCTAssertNil(longPressView.scrollableEdges.leftX, "nil")
                            } else {
                                if startDate > initDate {
                                    XCTAssertEqual(longPressView.scrollableEdges.leftX, days(initDate, startDate) * sectionWidth, "\(startDate)")
                                } else {
                                    XCTAssertNil(longPressView.scrollableEdges.leftX, "\(startDate)")
                                }
                            }
                            XCTAssertNil(longPressView.scrollableEdges.rightX, "nil")
                        }
                        continue
                    }
                    
                    if let endDate = endDate {
                        // out of range
                        if endDate < currentPageFirstDate {
                            XCTAssertEqual(longPressView.scrollableEdges.leftX, longPressView.contentViewWidth, "\(startDate, endDate)")
                            XCTAssertEqual(longPressView.scrollableEdges.rightX, longPressView.contentViewWidth, "\(startDate, endDate)")
                        } else if endDate <= currentPageLastDate {
                            XCTAssertNil(longPressView.scrollableEdges.leftX, "nil")
                            XCTAssertEqual(longPressView.scrollableEdges.rightX, longPressView.contentViewWidth, "\(startDate, endDate)")
                        } else {
                            XCTAssertNil(longPressView.scrollableEdges.leftX, "nil")
                            if longPressView.scrollType == .pageScroll {
                                XCTAssertNil(longPressView.scrollableEdges.rightX, "nil")
                            } else {
                                if endDate < lastDate {
                                    XCTAssertEqual(longPressView.scrollableEdges.rightX, (days(initDate, endDate) - CGFloat(longPressView.numOfDays) + 1) * sectionWidth, "\(endDate)")
                                } else {
                                    XCTAssertNil(longPressView.scrollableEdges.rightX, "\(endDate)")
                                }
                            }
                        }
                        continue
                    }
                    XCTAssertNil(longPressView.scrollableEdges.leftX, "start nil")
                    XCTAssertNil(longPressView.scrollableEdges.rightX, "end nil")
                }
            }
        }
        longPressView.setupCalendar(numOfDays: 3, setDate: date("2018-02-19"), allEvents: [:], scrollType: .pageScroll, scrollableRange: (nil, nil))
        testLongPressView()
        longPressView.scrollType = .sectionScroll
        longPressView.setHorizontalEdgesOffsetX()
        testLongPressView()
    }
}
