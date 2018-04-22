//
//  JZBaseEvent.swift
//  JZCalendarWeekView
//
//  Created by Jeff Zhang on 29/3/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit

open class JZBaseEvent: NSObject, NSCopying {
    
    open var startDate: Date
    open var endDate: Date
    
    //If a event crosses two days, it should be devided into two events but with different intraStartDate and intraEndDate
    //eg. startDate = 2018.03.29 14:00 endDate = 2018.03.30 03:00, then two events should be generated: 1. 0329 14:00 - 23:59(IntraEnd) 2. 0330 00:00(IntraStart) - 03:00
    open var intraStartDate: Date
    open var intraEndDate: Date
    
    public init(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
        self.intraStartDate = startDate
        self.intraEndDate = endDate
    }
    
    //Must be overrided
    open func copy(with zone: NSZone? = nil) -> Any {
        return JZBaseEvent.init(startDate: startDate, endDate: endDate)
    }
}
