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
    func registerSupplimentaryViews(_ viewClasses: [UICollectionReusableView.Type]) {
        viewClasses.forEach {
            self.register($0, forSupplementaryViewOfKind: $0.className, withReuseIdentifier: $0.className)
        }
    }
}

extension UICollectionViewFlowLayout {
    func registerDecorationViews(_ viewClasses: [UICollectionReusableView.Type]) {
        viewClasses.forEach {
            self.register($0, forDecorationViewOfKind: $0.className)
        }
    }
}

// Anchor Constraints from JZiOSFramework
extension UIView {
    
    func setAnchorConstraintsEqualTo(widthAnchor: CGFloat?=nil, heightAnchor: CGFloat?=nil, centerXAnchor: NSLayoutXAxisAnchor?=nil, centerYAnchor: NSLayoutYAxisAnchor?=nil) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let width = widthAnchor{
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = heightAnchor{
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
        if let centerX = centerXAnchor{
            self.centerXAnchor.constraint(equalTo: centerX).isActive = true
        }
        
        if let centerY = centerYAnchor{
            self.centerYAnchor.constraint(equalTo: centerY).isActive = true
        }
    }
    
    //bottomAnchor & trailingAnchor should be negative
    func setAnchorConstraintsEqualTo(widthAnchor: CGFloat?=nil, heightAnchor: CGFloat?=nil, topAnchor: (NSLayoutYAxisAnchor,CGFloat)?=nil, bottomAnchor: (NSLayoutYAxisAnchor,CGFloat)?=nil, leadingAnchor: (NSLayoutXAxisAnchor,CGFloat)?=nil, trailingAnchor: (NSLayoutXAxisAnchor,CGFloat)?=nil) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let width = widthAnchor{
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = heightAnchor{
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
        if let topY = topAnchor{
            self.topAnchor.constraint(equalTo: topY.0, constant: topY.1).isActive = true
        }
        
        if let botY = bottomAnchor{
            self.bottomAnchor.constraint(equalTo: botY.0, constant: botY.1).isActive = true
        }
        
        if let leadingX = leadingAnchor{
            self.leadingAnchor.constraint(equalTo: leadingX.0, constant: leadingX.1).isActive = true
        }
        
        if let trailingX = trailingAnchor{
            self.trailingAnchor.constraint(equalTo: trailingX.0, constant: trailingX.1).isActive = true
        }
    }
    
    func setAnchorCenterVerticallyTo(view: UIView, widthAnchor: CGFloat?=nil, heightAnchor: CGFloat?=nil, leadingAnchor: (NSLayoutXAxisAnchor,CGFloat)?=nil, trailingAnchor: (NSLayoutXAxisAnchor,CGFloat)?=nil) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        setAnchorConstraintsEqualTo(widthAnchor: widthAnchor, heightAnchor: heightAnchor, centerYAnchor: view.centerYAnchor)
        
        if let leadingX = leadingAnchor{
            self.leadingAnchor.constraint(equalTo: leadingX.0, constant: leadingX.1).isActive = true
        }
        
        if let trailingX = trailingAnchor{
            self.trailingAnchor.constraint(equalTo: trailingX.0, constant: trailingX.1).isActive = true
        }
    }
    
    func setAnchorCenterHorizontallyTo(view: UIView, widthAnchor: CGFloat?=nil, heightAnchor: CGFloat?=nil, topAnchor: (NSLayoutYAxisAnchor,CGFloat)?=nil, bottomAnchor: (NSLayoutYAxisAnchor,CGFloat)?=nil) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        setAnchorConstraintsEqualTo(widthAnchor: widthAnchor, heightAnchor: heightAnchor, centerXAnchor: view.centerXAnchor)
        
        if let topY = topAnchor{
            self.topAnchor.constraint(equalTo: topY.0, constant: topY.1).isActive = true
        }
        
        if let botY = bottomAnchor{
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
}

extension UILabel {
    class func getLabelWidth(_ height:CGFloat, font:UIFont, text:String) -> CGFloat{
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
    
    func add(component: Calendar.Component, value: Int) -> Date {
        return Calendar.current.date(byAdding: component, value: value, to: self)!
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        return Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self)!
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
    
    static func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: start, to: end).day!
    }
}
