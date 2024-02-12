//
//  CornerHeaderView.swift
//  JZCalendarWeekView
//
//  Created by Jeff Zhang on 28/3/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit

/// Top Left corner in collectionView (Supplementary View)
open class JZCornerHeader: UICollectionReusableView {
    private var monthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = JZWeekViewColors.columnHeaderDay
        return label
    }()

    public var selectedDate = Date() {
        didSet {
           updateMonthLabel(by: selectedDate)
        }
    }
    
    public var numOfDays = 3
    

    public override init(frame: CGRect) {
        super.init(frame: .zero)

        self.backgroundColor = JZWeekViewColors.mainCellColor
        setupBottomDivider()
        setupMonthLabel()
    }

    open func setupBottomDivider() {
        let bottomDivider = UIView()
        bottomDivider.backgroundColor = JZWeekViewColors.gridLine
        addSubview(bottomDivider)
        bottomDivider.setAnchorConstraintsEqualTo(heightAnchor: 0.5, bottomAnchor: (bottomAnchor, 0), leadingAnchor: (leadingAnchor, 0), trailingAnchor: (trailingAnchor, 0))
    }
    
    private func updateMonthLabel(by date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM."
        let updatedText = dateFormatter.string(from: date.add(component: .day, value: numOfDays + 1))
        
        monthLabel.text = updatedText
    }
    
    private func setupMonthLabel() {
        addSubview(monthLabel)
        
        NSLayoutConstraint.activate([
            monthLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            monthLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
