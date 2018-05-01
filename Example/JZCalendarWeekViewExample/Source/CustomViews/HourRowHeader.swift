//
//  HourRowHeader.swift
//  JZCalendarWeekViewExample
//
//  Created by Jeff Zhang on 23/4/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit
import JZCalendarWeekView

/// Custom Supplementary Hour Row Header View (No need to subclass, but **must** register and viewForSupplementaryElementOfKind)
class HourRowHeader: JZRowHeader {
    
    override func setupBasic() {
        // different dateFormat
        dateFormatter.dateFormat = "HH"
        lblTime.textColor = .orange
        lblTime.font = UIFont.systemFont(ofSize: 12)
    }
    
}
