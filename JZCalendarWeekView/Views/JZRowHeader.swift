//
//  JZRowHeader.swift
//  JZCalendarWeekView
//
//  Created by Jeff Zhang on 28/3/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit

open class JZRowHeader: UICollectionReusableView {
    
    public var lblTime = UILabel()
    public var dateFormatter = DateFormatter()
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        setupLayout()
        setupBasic()
    }
    
    private func setupLayout() {
        addSubview(lblTime)
        lblTime.setAnchorConstraintsEqualTo(centerXAnchor: centerXAnchor, centerYAnchor: centerYAnchor)
    }
    
    open func setupBasic() {
        dateFormatter.dateFormat = "HH:mm"
        lblTime.textColor = JZWeekViewColors.rowHeaderTime
        lblTime.font = UIFont.systemFont(ofSize: 12)
    }
    
    public func updateView(date: Date) {
        lblTime.text = dateFormatter.string(from: date)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
