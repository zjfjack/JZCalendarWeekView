//
//  JZAllDayHeader.swift
//  JZCalendarWeekView
//
//  Created by Jeff Zhang on 11/5/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit

open class JZAllDayHeader: UICollectionReusableView {

    /// The height of an allDayEvent within the allDayHeader (default: 25)
    public var eventHeight: CGFloat = 25
    let scrollView = UIScrollView()
    let stackView = UIStackView()

    private let scrollViewPadding: CGFloat = 3

    public override init(frame: CGRect) {
        super.init(frame: frame)

        setupBasic()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupBasic() {
        self.clipsToBounds = true
        setupScrollView()
        setupStackView()
    }

    private func setupScrollView() {
        self.addSubview(scrollView)
        scrollView.setAnchorConstraintsEqualTo(topAnchor: (topAnchor, scrollViewPadding), leadingAnchor: (leadingAnchor, scrollViewPadding), trailingAnchor: (trailingAnchor, -scrollViewPadding))
        let scrollViewBotCons = scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -scrollViewPadding)
        scrollViewBotCons.priority = .defaultHigh
        scrollViewBotCons.isActive = true
    }

    private func setupStackView() {
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
        if views.count == 0 {
            scrollView.removeFromSuperview()
        } else {
            if scrollView.superview == nil {
                setupScrollView()
            }
        }
        views.forEach {
            $0.heightAnchor.constraint(equalToConstant: eventHeight).isActive = true
            stackView.addArrangedSubview($0)
        }
    }
}
