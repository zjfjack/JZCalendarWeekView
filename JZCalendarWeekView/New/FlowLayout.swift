//
//  FlowLayout.swift
//  JZCalendarWeekView
//
//  Created by Jeff Zhang on 3/8/20.
//  Copyright © 2020 Jeff Zhang. All rights reserved.
//

import UIKit

class FlowLayout: UICollectionViewFlowLayout {

    var cachedAttributes = [UICollectionViewLayoutAttributes]()
    var contentBounds = CGRect.zero

    override func prepare() {
        super.prepare()

        guard let cv = collectionView else { return }

        cachedAttributes.removeAll()
        contentBounds = CGRect(origin: .zero, size: cv.bounds.size)

        // createAttributes()
    }

    override var collectionViewContentSize: CGSize {
        return contentBounds.size
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let cv = collectionView else { return false }

        return !newBounds.size.equalTo(cv.bounds.size)
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.item]
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cachedAttributes.filter { attributes -> Bool in
            return rect.intersects(attributes.frame)
        }
    }
}
