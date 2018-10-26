//
//  JZWorkDay.swift
//  JZCalendarWeekView
//
//  Created by Stefan on 26/10/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import Foundation

open class JZWorkDay: NSObject {
    
    public var startTime: Date
    public var endTime: Date
    
    public init(startTime: Date, endTime: Date) {
        self.startTime = startTime
        self.endTime = endTime
    }

}
