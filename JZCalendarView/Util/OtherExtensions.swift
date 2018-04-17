//
//  Extensions.swift
//  JZCalendarView
//
//  Created by Jeff Zhang on 16/4/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import Foundation

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}


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
