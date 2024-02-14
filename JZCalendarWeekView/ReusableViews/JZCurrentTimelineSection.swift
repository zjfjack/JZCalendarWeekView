//
//  JZCurrentTimelineSection.swift
//  JZCalendarWeekView
//
//  Created by Jeff Zhang on 28/3/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit

open class JZCurrentTimelineSection: UICollectionReusableView {

    public var halfBallView = UIView()
    public var lineView = UIView()
    let halfBallSize: CGFloat = 6

    public override init(frame: CGRect) {
        super.init(frame: .zero)

        setupUI()
    }

    open func setupUI() {
        self.addSubviews([halfBallView, lineView])
        halfBallView.setAnchorCenterVerticallyTo(view: self, 
                                                 widthAnchor: halfBallSize,
                                                 heightAnchor: halfBallSize,
                                                 leadingAnchor: (leadingAnchor, 3))
        
        lineView.setAnchorCenterVerticallyTo(view: self, 
                                             heightAnchor: 1,
                                             leadingAnchor: (self.leadingAnchor, 0),
                                             trailingAnchor: (trailingAnchor, 0))

        halfBallView.backgroundColor = UIColor.systemRed
        halfBallView.layer.cornerRadius = halfBallSize/2
        lineView.backgroundColor = UIColor.systemRed
        self.clipsToBounds = true
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
