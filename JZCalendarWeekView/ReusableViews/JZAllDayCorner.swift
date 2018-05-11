//
//  JZAllDayCorner.swift
//  JZCalendarWeekView
//
//  Created by Jeff Zhang on 11/5/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit

open class JZAllDayCorner: UICollectionReusableView {
    
    var lblTitle = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupBottomDivider()
    }
    
    open func setupUI() {
        self.addSubview(lblTitle)
        lblTitle.text = "All Day"
        lblTitle.textColor = JZWeekViewColors.allDayHeader
        lblTitle.font = UIFont.systemFont(ofSize: 12)
        lblTitle.setAnchorConstraintsEqualTo(centerXAnchor: self.centerXAnchor, centerYAnchor: self.centerYAnchor)
    }
    
    open func setupBottomDivider() {
        let bottomDivider = UIView()
        bottomDivider.backgroundColor = JZWeekViewColors.gridLine
        addSubview(bottomDivider)
        bottomDivider.setAnchorConstraintsEqualTo(heightAnchor: 0.5, bottomAnchor: (bottomAnchor, 0), leadingAnchor: (leadingAnchor, 0), trailingAnchor: (trailingAnchor, 0))
    }
    
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
