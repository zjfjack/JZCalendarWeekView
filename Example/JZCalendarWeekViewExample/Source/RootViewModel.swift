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
    
    private let firstDate = Date().add(component: .hour, value: 1)
    private let secondDate = Date().add(component: .day, value: 1)
    private let thirdDate = Date().add(component: .day, value: 2)
    
    lazy var events = [Event(title: "One", startDate: firstDate, endDate: firstDate.add(component: .hour, value: 1) , location: "Melbourne", eventType: 0),
                       Event(title: "Two", startDate: secondDate, endDate: secondDate.add(component: .hour, value: 4), location: "Sydney", eventType: 0),
                       Event(title: "Three", startDate: thirdDate, endDate: thirdDate.add(component: .hour, value: 2), location: "Tasmania", eventType: 1),
                       Event(title: "Four", startDate: thirdDate, endDate: thirdDate.add(component: .day, value: 2), location: "Canberra", eventType: 1)]
    
    lazy var eventsByDate: EventsByDate = JZWeekViewHelper.getIntraEventsByDate(originalEvents: events)
    
    var currentSelectedData: OptionsSelectedData!
}
