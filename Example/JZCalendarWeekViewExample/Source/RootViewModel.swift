//
//  RootViewModel.swift
//  JZCalendarViewExample
//
//  Created by Jeff Zhang on 3/4/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit
import JZCalendarWeekView

class RootViewModel: NSObject {
    
    private let currentDate = Date().add(component: .hour, value: 1)
    private let secondDate = Date().add(component: .day, value: -2)
    
    lazy var events = [Event(title: "One", startDate: currentDate, endDate: currentDate.add(component: .hour, value: 1) , location: "Melbourne", eventType: 0),
                       Event(title: "Two", startDate: currentDate, endDate: currentDate.add(component: .day, value: 1), location: "Sydney", eventType: 0),
                       Event(title: "Three", startDate: secondDate, endDate: secondDate.add(component: .minute, value: 40), location: "Tasmania", eventType: 1),
                       Event(title: "Four", startDate: currentDate, endDate: currentDate.add(component: .day, value: 3), location: "Canberra", eventType: 1)]
    
    var eventsByDate: EventsByDate!
    
    override init() {
        super.init()
        
        eventsByDate = JZWeekViewHelper.getIntraEventsByDate(originalEvents: events)
        
    }
    
}
