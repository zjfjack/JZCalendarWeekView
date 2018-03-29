//
//  UICollectionViewExtension.swift
//  JZCalendarView
//
//  Created by Jeff Zhang on 28/3/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import Foundation

extension UICollectionView {
    
    public func registerSupplimentaryViews(_ viewClasses: [UICollectionReusableView.Type]) {
        viewClasses.forEach {
            self.register($0, forSupplementaryViewOfKind: $0.className, withReuseIdentifier: $0.className)
        }
    }
    
}

extension UICollectionViewFlowLayout {
    
    public func registerDecorationViews(_ viewClasses: [UICollectionReusableView.Type]) {
        viewClasses.forEach {
            self.register($0, forDecorationViewOfKind: $0.className)
        }
    }
    
}
