//
//  RowHeader.swift
//  JZCalendarView
//
//  Created by Jeff Zhang on 28/3/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit

open class RowHeader: UICollectionReusableView {
    
    public var lblTime = UILabel()
    public var dateFormatter = DateFormatter()
    
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        addSubview(lblTime)
        lblTime.setAnchorConstraintsEqualTo(centerXAnchor: centerXAnchor, centerYAnchor: centerYAnchor)
        dateFormatter.dateFormat = "HH:mm"
        lblTime.textColor = WeekViewColors.rowHeaderTime
        lblTime.font = UIFont.systemFont(ofSize: 12)
    }
    
    public func updateCell(date: Date) {
        lblTime.text = dateFormatter.string(from: date)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
