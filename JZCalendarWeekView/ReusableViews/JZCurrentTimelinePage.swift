//
//  JZCurrentTimelinePage.swift
//  JZCalendarWeekView
//
//  Created by Jeff Zhang on 25/8/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit

class JZCurrentTimelinePage: UICollectionReusableView {
    
    public var ballView = UIView()
    public var lineView = UIView()
    let ballSize: CGFloat = 6
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setupUI()
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let pageAttributes = layoutAttributes as? JZCurrentTimelinePageLayoutAttributes {
            ballView.isHidden = !pageAttributes.needShowBallView
        }
    }
    
    private func setupUI() {
        self.addSubviews([ballView, lineView])
        ballView.setAnchorCenterVerticallyTo(view: self, widthAnchor: ballSize, heightAnchor: ballSize, leadingAnchor: (leadingAnchor, 1))
        lineView.setAnchorCenterVerticallyTo(view: self, heightAnchor: 1, leadingAnchor: (leadingAnchor, 0), trailingAnchor: (trailingAnchor, 0))
        
        ballView.backgroundColor = JZWeekViewColors.appleCalendarRed
        ballView.layer.cornerRadius = ballSize/2
        ballView.isHidden = true
        lineView.backgroundColor = JZWeekViewColors.appleCalendarRed
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
