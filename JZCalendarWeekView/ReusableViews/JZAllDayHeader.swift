//
//  JZAllDayHeader.swift
//  JZCalendarWeekView
//
//  Created by Jeff Zhang on 11/5/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit

open class JZAllDayHeader: UICollectionReusableView {
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupBasic()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBasic() {
        self.clipsToBounds = true
        self.addSubview(scrollView)
        scrollView.setAnchorConstraintsFullSizeTo(view: self, padding: 3)
        scrollView.addSubview(stackView)
        stackView.setAnchorConstraintsFullSizeTo(view: scrollView)
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        stackView.spacing = 3
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
    }
    
    /// All-Day Header is reused as SupplementaryView, it should be updated when viewForSupplementaryElementOfKind called
    ///
    /// - Parameter views: The views your want to add to stackView
    public func updateView(views: [UIView]) {
        stackView.subviews.forEach { $0.removeFromSuperview() }
        views.forEach {
            $0.heightAnchor.constraint(equalToConstant: 25).isActive = true
            stackView.addArrangedSubview($0)
        }
    }
}
