//
//  LongPressEventCell.swift
//  JZCalendarWeekViewExample
//
//  Created by Jeff Zhang on 2/5/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit
import JZCalendarWeekView

// If you want to use Move Type LongPressWeekView, you have to inherit from JZLongPressEventCell and update event when you configure cell every time
class LongPressEventCell: JZLongPressEventCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var borderView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupBasic()
        // You have to set the background color in contentView instead of cell background color, because cell reuse problems in collectionview
        // When setting alpha to cell, the alpha will back to 1 when collectionview scrolled, which means that moving cell will not be translucent
        self.contentView.backgroundColor = UIColor(hex: 0xEEF7FF)
    }
    
    func setupBasic() {
        self.clipsToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 5
        layer.shadowOpacity = 0
        locationLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        borderView.backgroundColor = UIColor(hex: 0x0899FF)
    }

    func configureCell(event: AllDayEvent, isAllDay: Bool = false) {
        self.event = event
        locationLabel.text = event.location
        titleLabel.text = event.title
        
        locationLabel.isHidden = isAllDay
    }

}
