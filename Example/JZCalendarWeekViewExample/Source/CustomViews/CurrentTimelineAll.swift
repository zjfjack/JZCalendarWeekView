//
//  CurrentTimelineAll.swift
//  JZCalendarWeekViewExample
//
//  Created by Jeff Zhang on 28/8/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit

class CurrentTimelineAll: UICollectionReusableView {
    
    public var ballView = UIView()
    public var lineView = UIView()
    let ballSize: CGFloat = 6
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setupUI()
    }
    
    open func setupUI() {
        self.addSubviews([ballView, lineView])
        ballView.setAnchorCenterVerticallyTo(view: self, widthAnchor: ballSize, heightAnchor: ballSize, leadingAnchor: (leadingAnchor, 2))
        lineView.setAnchorCenterVerticallyTo(view: self, heightAnchor: 1, leadingAnchor: (leadingAnchor, 0), trailingAnchor: (trailingAnchor, 0))
        
        ballView.backgroundColor = .purple
        ballView.layer.cornerRadius = ballSize/2
        ballView.isHidden = true
        lineView.backgroundColor = .purple
    }
    
    open func updateView(needShowBallView: Bool) {
        ballView.isHidden = !needShowBallView
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
