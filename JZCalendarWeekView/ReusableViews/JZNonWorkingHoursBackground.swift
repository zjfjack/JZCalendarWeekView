//
//  JZNonWorkingHoursBackground.swift
//  JZCalendarWeekView
//
//  Created by Stefan on 26/10/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import Foundation

/// The background drawed on layout to outline non working hours
class JZNonWorkingHoursBackground: UICollectionReusableView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = JZWeekViewColors.nonWorkingHours
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
