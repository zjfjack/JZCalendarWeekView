//
//  CornerHeaderBackground.swift
//  JZCalendarView
//
//  Created by Jeff Zhang on 28/3/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit

class CornerHeaderBackground: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.blue
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
