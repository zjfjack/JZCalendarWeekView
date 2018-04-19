//
//  CurrentTimeIndicator.swift
//  JZCalendarWeekView
//
//  Created by Jeff Zhang on 28/3/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import Foundation

open class CurrentTimeIndicator: UICollectionReusableView {
    
    var halfBallView = UIView()
    var lineView = UIView()
    let halfBallSize: CGFloat = 10
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setupUI()
    }
    
    func setupUI() {
        self.addSubviews([halfBallView, lineView])
        halfBallView.setAnchorCenterVerticallyTo(view: self, widthAnchor: halfBallSize, heightAnchor: halfBallSize, leadingAnchor: (leadingAnchor, -5))
        lineView.setAnchorCenterVerticallyTo(view: self, heightAnchor: 1, leadingAnchor: (halfBallView.trailingAnchor, 0), trailingAnchor: (trailingAnchor, 0))
        
        halfBallView.backgroundColor = WeekViewColors.today
        halfBallView.layer.cornerRadius = halfBallSize/2
        lineView.backgroundColor = WeekViewColors.today
        self.clipsToBounds = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
