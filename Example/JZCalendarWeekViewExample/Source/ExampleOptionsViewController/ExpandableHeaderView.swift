//
//  ExpandableHeaderView.swift
//  JZCalendarViewExample
//
//  Created by Jeff Zhang on 12/4/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit

protocol ExpandableHeaderViewDelegate: class {
    func toggleSection(section: Int)
}

class ExpandableHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSelectedValue: UILabel!
    weak var delegate: ExpandableHeaderViewDelegate?
    var section: Int!

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupBasic()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBasic()
    }

    func setupBasic() {
        self.contentView.backgroundColor = .white
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(headerViewTapped)))
    }

    func updateHeaderView(section: Int, title: String, subTitle: String) {
        self.section = section
        lblTitle.text = title
        lblSelectedValue.text = subTitle
    }

    @objc func headerViewTapped() {
        tapAnimation()
        delegate?.toggleSection(section: section)
    }

    private func tapAnimation() {
        UIView.animate(withDuration: 0.2,
                       animations: { self.contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5) },
                       completion: {_ in
                        UIView.animate(withDuration: 0.2) {
                            self.contentView.backgroundColor = .white
                        }
        })
    }

}
