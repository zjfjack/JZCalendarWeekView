//
//  JZWeekViewColors.swift
//  JZCalendarWeekView
//
//  Created by Jeff Zhang on 29/3/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit

/// cannot change for now, will implement theme in the future
class JZWeekViewColors {

    class var columnHeaderWeekday: UIColor { return UIColor(hex: 0x757575) }
    class var columnHeaderDay: UIColor { return UIColor(hex: 0x757575) }
    class var allDayHeader: UIColor { return UIColor(hex: 0x757575) }
    class var rowHeaderTime: UIColor { return UIColor(hex: 0x999999) }
    class var gridLine: UIColor { return UIColor.lightGray }

    class var today: UIColor { return UIColor(hex: 0x0089FF) }
    class var appleCalendarRed: UIColor { return UIColor(hex: 0xFC3D39) }
}

extension UIColor {

    static var appPrimary: UIColor { UIColor(red: 0.98, green: 0.831, blue: 0, alpha: 1) }
    static var appSecondary: UIColor { UIColor(red: 0.416, green: 0.659, blue: 0.933, alpha: 1) }
    static var appWhite: UIColor { UIColor(red: 1, green: 1, blue: 1, alpha: 1) }
    static var field: UIColor { UIColor(red: 0.98, green: 0.988, blue: 0.988, alpha: 1) }

    static var appAccent: UIColor { UIColor(red: 0.231, green: 0.294, blue: 0.322, alpha: 1) }
    static var accent400: UIColor { UIColor(red: 0.337, green: 0.427, blue: 0.463, alpha: 1) }
    static var accent300: UIColor { UIColor(red: 0.463, green: 0.51, blue: 0.529, alpha: 1) }
    static var accent200: UIColor { UIColor(red: 0.62, green: 0.651, blue: 0.667, alpha: 1) }
    static var accent150: UIColor { UIColor(red: 0.749, green: 0.769, blue: 0.78, alpha: 1) }
    static var accent100: UIColor { UIColor(red: 0.875, green: 0.886, blue: 0.89, alpha: 1) }
    static var accent50: UIColor { UIColor(red: 0.953, green: 0.965, blue: 0.969, alpha: 1) }
        
    static var informationBase: UIColor { UIColor(red: 0.416, green: 0.659, blue: 0.933, alpha: 1) }
    static var information200: UIColor { UIColor(red: 0.622, green: 0.782, blue: 0.962, alpha: 1) }
    static var information100: UIColor { UIColor(red: 0.9, green: 0.947, blue: 1, alpha: 1) }
    
    static var successBase: UIColor { UIColor(red: 0.227, green: 0.812, blue: 0.49, alpha: 1) }
    static var success200: UIColor { UIColor(red: 0.651, green: 0.914, blue: 0.769, alpha: 1) }
    static var success100: UIColor { UIColor(red: 0.922, green: 0.98, blue: 0.949, alpha: 1) }
    
    static var warningBase: UIColor { UIColor(red: 0.96, green: 0.73, blue: 0.269, alpha: 1) }
    static var warning200: UIColor { UIColor(red: 0.98, green: 0.863, blue: 0.635, alpha: 1) }
    static var warning100: UIColor { UIColor(red: 0.996, green: 0.973, blue: 0.925, alpha: 1) }
    
    static var errorBase: UIColor { UIColor(red: 0.957, green: 0.369, blue: 0.267, alpha: 1) }
    static var error200: UIColor { UIColor(red: 0.94, green: 0.604, blue: 0.548, alpha: 1) }
    static var error100: UIColor { UIColor(red: 0.996, green: 0.937, blue: 0.925, alpha: 1) }

    static var statusUnsent: UIColor { UIColor(red: 0.835, green: 0.455, blue: 0.894, alpha: 1) }
    static var statusPending: UIColor { UIColor(red: 0.983, green: 0.67, blue: 0.201, alpha: 1) }
    static var statusApproved: UIColor { UIColor(red: 0.416, green: 0.659, blue: 0.933, alpha: 1) }
    static var statusDenied: UIColor { UIColor(red: 1, green: 0.435, blue: 0.392, alpha: 1) }
    static var statusWon: UIColor { UIColor(red: 0.757, green: 0.659, blue: 0.49, alpha: 1) }
    static var statusArchived: UIColor { UIColor(red: 0.62, green: 0.651, blue: 0.667, alpha: 1) }

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
    // Get UIColor by hex
    fileprivate convenience init(hex: Int, a: CGFloat = 1.0) {
        self.init(
            red: (hex >> 16) & 0xFF,
            green: (hex >> 8) & 0xFF,
            blue: hex & 0xFF,
            a: a
        )
    }
}
