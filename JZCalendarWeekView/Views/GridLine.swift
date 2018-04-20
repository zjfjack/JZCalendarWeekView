//
//  GridLine.swift
//  JZCalendarWeekView
//
//  Created by Jeff Zhang on 28/3/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit

open class GridLine: UICollectionReusableView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = WeekViewColors.gridLine
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
