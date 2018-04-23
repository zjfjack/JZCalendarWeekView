//
//  HourRowHeader.swift
//  JZCalendarWeekViewExample
//
//  Created by Jeff Zhang on 23/4/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit
import JZCalendarWeekView

class HourRowHeader: JZRowHeader {
    
    override func setupBasic() {
        dateFormatter.dateFormat = "HH"
        lblTime.textColor = .blue
        lblTime.font = UIFont.systemFont(ofSize: 12)
    }
    
}
