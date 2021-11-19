//
//  JZWeekView.swift
//  JZCalendarWeekView
//
//  Created by Jeff Zhang on 3/8/20.
//  Copyright © 2020 Jeff Zhang. All rights reserved.
//

import UIKit

open class JZWeekView: UIView {

    public private(set) var collectionView: JZCollectionView {
        didSet {
//            collectionView.delegate = self
//            collectionView.dataSource = self
            collectionView.isDirectionalLockEnabled = true
            collectionView.bounces = false
            collectionView.showsVerticalScrollIndicator = false
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.backgroundColor = UIColor.white
            addSubview(collectionView)
            collectionView.setAnchorConstraintsFullSizeTo(view: self)
        }
    }
    public private(set) var flowLayout: JZWeekViewFlowLayout {
        didSet {
            self.collectionView.collectionViewLayout = flowLayout
        }
    }

    //public private(set) var collectionViewDelegate

    init(flowLayout: JZWeekViewFlowLayout = JZWeekViewFlowLayout(),
         collectionView: JZCollectionView = JZCollectionView()) {
        self.flowLayout = flowLayout
        self.collectionView = collectionView
        super.init(frame: .zero)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
