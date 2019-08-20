//
//  JZLongPressEventCell.swift
//  JZCalendarWeekView
//
//  Created by Jeff Zhang on 28/3/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit

// If you want to use Move Type LongPressWeekView, you have to subclass this class
open class JZLongPressEventCell: UICollectionViewCell {

    // Make sure update your event when each time configure cell in cellForRowAt
    public var event: JZBaseEvent!

    // You have to set the background color in contentView instead of cell background color, because cell reuse problems in collectionview
    // When setting alpha to cell, the alpha will back to 1 when collectionview scrolled, which means that moving cell will not be translucent
    // Check the example for details eg. self.contentView.backgroundColor = .blue
}
