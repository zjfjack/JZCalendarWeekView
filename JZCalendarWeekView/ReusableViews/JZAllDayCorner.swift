//
//  JZAllDayCorner.swift
//  JZCalendarWeekView
//
//  Created by Jeff Zhang on 11/5/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit

open class JZAllDayCorner: UICollectionReusableView {

    public var lblTitle = UILabel()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
        setupBottomDivider()
    }

    open func setupUI() {
        self.backgroundColor = JZWeekViewColors.allDayCellBackgroundColor
        self.clipsToBounds = true
        self.addSubview(lblTitle)
        lblTitle.text = NSLocalizedString("all-day", comment: "")
        lblTitle.numberOfLines = 2
        lblTitle.textColor = JZWeekViewColors.allDayHeader
        lblTitle.font = UIFont.systemFont(ofSize: 12)
        lblTitle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            lblTitle.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            lblTitle.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            lblTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -1),
            lblTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 1)
        ])
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
