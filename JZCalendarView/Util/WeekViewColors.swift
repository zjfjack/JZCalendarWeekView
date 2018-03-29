//
//  WeekViewColors.swift
//  JZCalendarView
//
//  Created by Jeff Zhang on 29/3/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import Foundation

open class WeekViewColors {
    
    open class var columnHeaderWeekday: UIColor { return UIColor(hex: 0x757575) }
    open class var columnHeaderDay: UIColor { return UIColor(hex: 0x757575) }
    open class var rowHeaderTime: UIColor { return UIColor(hex: 0x999999) }
    open class var gridLine: UIColor { return UIColor.darkGray }
    
    open class var today: UIColor { return UIColor(hex: 0x0089FF) }
}


extension UIColor {
    
    fileprivate convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: a
        )
    }
    //Get UIColor by hex
    fileprivate convenience init(hex: Int, a: CGFloat = 1.0) {
        self.init(
            red: (hex >> 16) & 0xFF,
            green: (hex >> 8) & 0xFF,
            blue: hex & 0xFF,
            a: a
        )
    }
}
