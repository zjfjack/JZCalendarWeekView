//
//  JZEvent.swift
//  JZCalendarViewExample
//
//  Created by Jeff Zhang on 3/4/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit
import JZCalendarWeekView

class JZEvent: BaseEvent {
    
    var location: String
    var eventType: Int
    var title: String
    
    init(title: String, startDate: Date, endDate: Date, location: String, eventType: Int) {
        self.location = location
        self.eventType = eventType
        self.title = title
        super.init(startDate: startDate, endDate: endDate)
    }
    
    override func copy(with zone: NSZone?) -> Any {
        return JZEvent(title: title, startDate: startDate, endDate: endDate, location: location, eventType: eventType)
    }
    
    
}
