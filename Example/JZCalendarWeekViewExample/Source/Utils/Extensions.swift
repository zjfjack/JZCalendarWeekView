//
//  Extensions.swift
//  JZCalendarViewExample
//
//  Created by Jeff Zhang on 3/4/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit
import JZCalendarWeekView

extension Date {

    func add(component: Calendar.Component, value: Int) -> Date {
        return Calendar.current.date(byAdding: component, value: value, to: self)!
    }

    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}

extension UIColor {

    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: alpha
        )
    }
    // Get UIColor by hex
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: (hex >> 16) & 0xFF,
            green: (hex >> 8) & 0xFF,
            blue: hex & 0xFF,
            alpha: alpha
        )
    }
}

extension NSObject {

    class var className: String {
        return String(describing: self)
    }
}

extension JZHourGridDivision {
    var displayText: String {
        switch self {
        case .noneDiv: return "No Division"
        default:
            return self.rawValue.description + " mins"
        }
    }
}

extension DayOfWeek {
    var dayName: String {
        switch self {
        case .Sunday: return "Sunday"
        case .Monday: return "Monday"
        case .Tuesday: return "Tuesday"
        case .Wednesday: return "Wednesday"
        case .Thursday: return "Thursday"
        case .Friday: return "Friday"
        case .Saturday: return "Saturday"
        }
    }

    static var dayOfWeekList: [DayOfWeek] {
        return [.Sunday, .Monday, .Tuesday, .Wednesday, .Thursday, .Friday, .Saturday]
    }
}

extension JZScrollType {
    var displayText: String {
        switch self {
        case .pageScroll:
            return "Page Scroll"
        case .sectionScroll:
            return "Section Scroll"
        }
    }
}

// Anchor Constraints from JZiOSFramework
extension UIView {

    func setAnchorConstraintsEqualTo(widthAnchor: CGFloat?=nil, heightAnchor: CGFloat?=nil, centerXAnchor: NSLayoutXAxisAnchor?=nil, centerYAnchor: NSLayoutYAxisAnchor?=nil) {

        self.translatesAutoresizingMaskIntoConstraints = false

        if let width = widthAnchor {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }

        if let height = heightAnchor {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }

        if let centerX = centerXAnchor {
            self.centerXAnchor.constraint(equalTo: centerX).isActive = true
        }

        if let centerY = centerYAnchor {
            self.centerYAnchor.constraint(equalTo: centerY).isActive = true
        }
    }

    // bottomAnchor & trailingAnchor should be negative
    func setAnchorConstraintsEqualTo(widthAnchor: CGFloat? = nil, heightAnchor: CGFloat? = nil,
                                     topAnchor: (NSLayoutYAxisAnchor, CGFloat)? = nil, bottomAnchor: (NSLayoutYAxisAnchor, CGFloat)? = nil,
                                     leadingAnchor: (NSLayoutXAxisAnchor, CGFloat)? = nil, trailingAnchor: (NSLayoutXAxisAnchor, CGFloat)? = nil) {

        self.translatesAutoresizingMaskIntoConstraints = false

        if let width = widthAnchor {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }

        if let height = heightAnchor {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }

        if let topY = topAnchor {
            self.topAnchor.constraint(equalTo: topY.0, constant: topY.1).isActive = true
        }

        if let botY = bottomAnchor {
            self.bottomAnchor.constraint(equalTo: botY.0, constant: botY.1).isActive = true
        }

        if let leadingX = leadingAnchor {
            self.leadingAnchor.constraint(equalTo: leadingX.0, constant: leadingX.1).isActive = true
        }

        if let trailingX = trailingAnchor {
            self.trailingAnchor.constraint(equalTo: trailingX.0, constant: trailingX.1).isActive = true
        }
    }

    func setAnchorCenterVerticallyTo(view: UIView, widthAnchor: CGFloat?=nil, heightAnchor: CGFloat?=nil, leadingAnchor: (NSLayoutXAxisAnchor, CGFloat)?=nil, trailingAnchor: (NSLayoutXAxisAnchor, CGFloat)?=nil) {
        self.translatesAutoresizingMaskIntoConstraints = false

        setAnchorConstraintsEqualTo(widthAnchor: widthAnchor, heightAnchor: heightAnchor, centerYAnchor: view.centerYAnchor)

        if let leadingX = leadingAnchor {
            self.leadingAnchor.constraint(equalTo: leadingX.0, constant: leadingX.1).isActive = true
        }

        if let trailingX = trailingAnchor {
            self.trailingAnchor.constraint(equalTo: trailingX.0, constant: trailingX.1).isActive = true
        }
    }

    func setAnchorCenterHorizontallyTo(view: UIView, widthAnchor: CGFloat?=nil, heightAnchor: CGFloat?=nil, topAnchor: (NSLayoutYAxisAnchor, CGFloat)?=nil, bottomAnchor: (NSLayoutYAxisAnchor, CGFloat)?=nil) {
        self.translatesAutoresizingMaskIntoConstraints = false

        setAnchorConstraintsEqualTo(widthAnchor: widthAnchor, heightAnchor: heightAnchor, centerXAnchor: view.centerXAnchor)

        if let topY = topAnchor {
            self.topAnchor.constraint(equalTo: topY.0, constant: topY.1).isActive = true
        }

        if let botY = bottomAnchor {
            self.bottomAnchor.constraint(equalTo: botY.0, constant: botY.1).isActive = true
        }
    }

    func setAnchorConstraintsFullSizeTo(view: UIView, padding: CGFloat = 0) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: view.topAnchor, constant: padding).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding).isActive = true
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding).isActive = true
    }

    func addSubviews(_ views: [UIView]) {
        views.forEach({ self.addSubview($0)})
    }
}
