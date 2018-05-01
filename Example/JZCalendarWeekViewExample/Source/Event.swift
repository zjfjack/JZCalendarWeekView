//
//  Event.swift
//  JZCalendarViewExample
//
//  Created by Jeff Zhang on 3/4/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit
import JZCalendarWeekView

class Event: JZBaseEvent {
    
    var location: String
    /// Not used for now
    var eventType: Int
    var title: String
    var id: String
    
    init(id: String, title: String, startDate: Date, endDate: Date, location: String, eventType: Int) {
        self.id = id
        self.location = location
        self.eventType = eventType
        self.title = title
        super.init(startDate: startDate, endDate: endDate)
    }
    
    override func copy(with zone: NSZone?) -> Any {
        return Event(id: id, title: title, startDate: startDate, endDate: endDate, location: location, eventType: eventType)
    }
    
    
}
