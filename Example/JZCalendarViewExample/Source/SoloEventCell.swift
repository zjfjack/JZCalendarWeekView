//
//  SoloEventCell.swift
//  timegenii
//
//  Created by Jeff Zhang on 14/9/17.
//  Copyright © 2017 unimelb. All rights reserved.
//

import UIKit
import JZCalendarView

class SoloEventCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var borderView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupBasic()
    }
    
    func setupBasic() {
        self.clipsToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 5
        layer.shadowOpacity = 0
        locationLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        self.backgroundColor = UIColor(hex: 0xEEF7FF)
        borderView.backgroundColor = UIColor(hex: 0x0899FF)
    }
    
    func updateView(event: JZEvent) {
        locationLabel.text = event.location
        titleLabel.text = event.title
    }

}
