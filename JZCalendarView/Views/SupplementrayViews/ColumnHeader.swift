//
//  ColumnHeader.swift
//  JZCalendarView
//
//  Created by Jeff Zhang on 28/3/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit

open class ColumnHeader: UICollectionReusableView {
    
    public var lblDay = UILabel()
    public var lblWeekday = UILabel()
    let calendarCurrent = Calendar.current
    let dateFormatter = DateFormatter()
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [lblWeekday, lblDay])
        stackView.axis = .vertical
        stackView.spacing = 2
        addSubview(stackView)
        stackView.setAnchorConstraintsEqualTo(centerXAnchor: centerXAnchor, centerYAnchor: centerYAnchor)
        lblDay.textAlignment = .center
        lblWeekday.textAlignment = .center
        lblDay.font = UIFont.systemFont(ofSize: 17)
        lblWeekday.font = UIFont.systemFont(ofSize: 12)
    }
    
    public func updateCell(date: Date) {
        let weekday = calendarCurrent.component(.weekday, from: date) - 1
        
        lblDay.text = String(calendarCurrent.component(.day, from: date))
        lblWeekday.text = dateFormatter.shortWeekdaySymbols[weekday].uppercased()
        
        if date.isToday {
            lblDay.textColor = WeekViewColors.today
            lblWeekday.textColor = WeekViewColors.today
        } else {
            lblDay.textColor = WeekViewColors.columnHeaderDay
            lblWeekday.textColor = WeekViewColors.columnHeaderDay
        }
        //set this to avoid columnheader hiding the botline in columnheaderbackground
        backgroundColor = UIColor.clear
    }
    
}
