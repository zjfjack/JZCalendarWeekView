//
//  JZAllDayHeader.swift
//  JZCalendarWeekView
//
//  Created by Jeff Zhang on 11/5/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit

open class JZAllDayHeader: UICollectionReusableView {
    
    let stackView = UIStackView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupBasic()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBasic() {
        self.addSubview(stackView)
        stackView.setAnchorConstraintsFullSizeTo(view: self, padding: 2)
        stackView.spacing = 2
        stackView.axis = .vertical
    }
    
    /// All-Day Header is reused as SupplementaryView, it should be updated when viewForSupplementaryElementOfKind called
    ///
    /// - Parameter views: <#views description#>
    public func updateView(views: [UIView]) {
        stackView.subviews.forEach { $0.removeFromSuperview() }
        views.forEach { stackView.addArrangedSubview($0) }
    }
}
