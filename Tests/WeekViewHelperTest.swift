//
//  WeekViewHelperTest.swift
//  JZCalendarWeekViewTests
//
//  Created by Jeff Zhang on 3/4/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import XCTest
@testable import JZCalendarWeekView

class WeekViewHelperTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetIntraEventsByDateSameDateEvents() {
        let testDate = Date().startOfDay
        let sameDayEvent = JZBaseEvent(id: UUID().uuidString, startDate: testDate, endDate: testDate.add(component: .hour, value: 3))
        let sameDateResults = JZWeekViewHelper.getIntraEventsByDate(originalEvents: [sameDayEvent])
        XCTAssertTrue(sameDateResults.keys.count == 1, "Result should be only one date")
        
        if let testDateEvents = sameDateResults[testDate], testDateEvents.count == 1 {
            let event = testDateEvents[0]
            XCTAssertEqual(event.intraStartDate, sameDayEvent.intraStartDate)
            XCTAssertEqual(event.intraEndDate, sameDayEvent.intraEndDate)
        } else {
            XCTFail()
        }
    }
    
    func testGetIntraEventsByDateCrossingDateEvents() {
        let testStartDate = Date().set(hour: 22, minute: 0, second: 0)
        let testSecondDate = testStartDate.add(component: .day, value: 1)
        let testThirdDate = testStartDate.add(component: .day, value: 2)
        // Cross within 24 hours will still count as 2 days
        let testFourthDate = testStartDate.add(component: .hour, value: 3)
        
        let crossTwoDayEvent = JZBaseEvent(id: UUID().uuidString, startDate: testStartDate, endDate: testThirdDate)
        let twoDayResults = JZWeekViewHelper.getIntraEventsByDate(originalEvents: [crossTwoDayEvent])
        XCTAssertEqual(twoDayResults.keys.count, 3, "Result should be three dates")
        
        if let firstDayEvents = twoDayResults[testStartDate.startOfDay], firstDayEvents.count == 1 {
            let event = firstDayEvents[0]
            XCTAssertEqual(event.intraStartDate, crossTwoDayEvent.intraStartDate)
            XCTAssertEqual(event.intraEndDate, testStartDate.endOfDay)
            XCTAssertNotEqual(event.intraEndDate, crossTwoDayEvent.intraEndDate, "Copy problem")
        } else {
            XCTFail()
        }
        
        if let secondDayEvents = twoDayResults[testSecondDate.startOfDay], secondDayEvents.count == 1 {
            let event = secondDayEvents[0]
            XCTAssertNotEqual(event.intraStartDate, crossTwoDayEvent.intraStartDate, "Copy problem")
            XCTAssertNotEqual(event.intraEndDate, crossTwoDayEvent.intraEndDate, "Copy problem")
            XCTAssertEqual(event.intraStartDate, testSecondDate.startOfDay)
            XCTAssertEqual(event.intraEndDate, testSecondDate.endOfDay)
        } else {
            XCTFail()
        }
        
        if let thirdDayEvents = twoDayResults[testThirdDate.startOfDay], thirdDayEvents.count == 1 {
            let event = thirdDayEvents[0]
            XCTAssertNotEqual(event.intraStartDate, crossTwoDayEvent.intraStartDate, "Copy problem")
            XCTAssertEqual(event.intraStartDate, testThirdDate.startOfDay)
            XCTAssertEqual(event.intraEndDate, crossTwoDayEvent.intraEndDate)
        } else {
            XCTFail()
        }
        
        // Within 24 hours
        
        let crossThreeHourEvent = JZBaseEvent(id: UUID().uuidString, startDate: testStartDate, endDate: testFourthDate)
        let threeHourResults = JZWeekViewHelper.getIntraEventsByDate(originalEvents: [crossThreeHourEvent])
        
        XCTAssertEqual(threeHourResults.keys.count, 2, "Result should be two dates")
        
        if let firstDayEvents = threeHourResults[testStartDate.startOfDay], firstDayEvents.count == 1 {
            let event = firstDayEvents[0]
            XCTAssertEqual(event.intraStartDate, crossTwoDayEvent.intraStartDate)
            XCTAssertEqual(event.intraEndDate, testStartDate.endOfDay)
            XCTAssertNotEqual(event.intraEndDate, crossTwoDayEvent.intraEndDate, "Copy problem")
        } else {
            XCTFail()
        }
        
        if let secondDayEvents = threeHourResults[testFourthDate.startOfDay], secondDayEvents.count == 1 {
            let event = secondDayEvents[0]
            XCTAssertNotEqual(event.intraStartDate, crossThreeHourEvent.intraStartDate, "Copy problem")
            XCTAssertEqual(event.intraStartDate, testFourthDate.startOfDay)
            XCTAssertEqual(event.intraEndDate, crossThreeHourEvent.intraEndDate)
        } else {
            XCTFail()
        }
    }
    
}
