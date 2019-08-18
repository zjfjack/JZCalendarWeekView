//
//  Extensions.swift
//  JZCalendarWeekView
//
//  Created by Jeff Zhang on 16/4/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit

extension NSObject {
    static var className: String {
        return String(describing: self)
    }
}

extension UICollectionView {

    func setContentOffsetWithoutDelegate(_ contentOffset: CGPoint, animated: Bool) {
        let tempDelegate = self.delegate
        self.delegate = nil
        self.setContentOffset(contentOffset, animated: animated)
        self.delegate = tempDelegate
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
    func setAnchorConstraintsEqualTo(widthAnchor: CGFloat?=nil, heightAnchor: CGFloat?=nil, topAnchor: (NSLayoutYAxisAnchor, CGFloat)?=nil, bottomAnchor: (NSLayoutYAxisAnchor, CGFloat)?=nil, leadingAnchor: (NSLayoutXAxisAnchor, CGFloat)?=nil, trailingAnchor: (NSLayoutXAxisAnchor, CGFloat)?=nil) {

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

    var snapshot: UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }

    func setDefaultShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.05
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
    }
}

extension UILabel {
    class func getLabelWidth(_ height: CGFloat, font: UIFont, text: String) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: height))
        label.font = font
        label.numberOfLines = 0
        label.text = text
        label.sizeToFit()
        return label.frame.width
    }
}

extension Date {

    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }

    var isYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }

    var isTomorrow: Bool {
        return Calendar.current.isDateInTomorrow(self)
    }

    static func getCurrentWeekDays(firstDayOfWeek: DayOfWeek?=nil) -> [Date] {
        var calendar = Calendar.current
        calendar.firstWeekday = (firstDayOfWeek ?? .Sunday).rawValue
        let today = calendar.startOfDay(for: Date())
        let dayOfWeek = calendar.component(.weekday, from: today)
        let weekdays = calendar.range(of: .weekday, in: .weekOfYear, for: today)!
        let days = (weekdays.lowerBound ..< weekdays.upperBound).compactMap { calendar.date(byAdding: .day, value: $0 - dayOfWeek, to: today) }
        return days
    }

    func add(component: Calendar.Component, value: Int) -> Date {
        return Calendar.current.date(byAdding: component, value: value, to: self)!
    }

    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        return self.set(hour: 23, minute: 59, second: 59)
    }

    func getDayOfWeek() -> DayOfWeek {
        let weekDayNum = Calendar.current.component(.weekday, from: self)
        let weekDay = DayOfWeek(rawValue: weekDayNum)!
        return weekDay
    }

    func getTimeIgnoreSecondsFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }

    static func daysBetween(start: Date, end: Date, ignoreHours: Bool) -> Int {
        let startDate = ignoreHours ? start.startOfDay : start
        let endDate = ignoreHours ? end.startOfDay : end
        return Calendar.current.dateComponents([.day], from: startDate, to: endDate).day!
    }

    static let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second, .weekday]
    private var dateComponents: DateComponents {
        return  Calendar.current.dateComponents(Date.components, from: self)
    }

    var year: Int { return dateComponents.year! }
    var month: Int { return dateComponents.month! }
    var day: Int { return dateComponents.day! }
    var hour: Int { return dateComponents.hour! }
    var minute: Int { return dateComponents.minute! }
    var second: Int { return dateComponents.second! }

    var weekday: Int { return dateComponents.weekday! }

    func set(year: Int?=nil, month: Int?=nil, day: Int?=nil, hour: Int?=nil, minute: Int?=nil, second: Int?=nil, tz: String?=nil) -> Date {
        let timeZone = Calendar.current.timeZone
        let year = year ?? self.year
        let month = month ?? self.month
        let day = day ?? self.day
        let hour = hour ?? self.hour
        let minute = minute ?? self.minute
        let second = second ?? self.second
        let dateComponents = DateComponents(timeZone: timeZone, year: year, month: month, day: day, hour: hour, minute: minute, second: second)
        let date = Calendar.current.date(from: dateComponents)
        return date!
    }
}

extension CGFloat {

    func toDecimal1Value() -> CGFloat {
        return (self * 10).rounded() / 10
    }

}
