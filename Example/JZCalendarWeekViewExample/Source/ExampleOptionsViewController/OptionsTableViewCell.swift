//
//  OptionsTableViewCell.swift
//  JZCalendarViewExample
//
//  Created by Jeff Zhang on 12/4/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit

protocol OptionsCellDelegate: class {
    func selectedValueChanged(section: Int)
}

class OptionsTableViewCell: UITableViewCell {

    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!

    weak var delegate: OptionsCellDelegate?
    var pickerData: ExpandableData!
    var section: Int!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupNormalPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
    }

    func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.locale = Calendar.current.locale
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
    }

    func updateCell(data: ExpandableData, section: Int) {
        self.pickerData = data
        self.section = section
        setupNormalPickerView()
        setupDatePicker()

        let noIndexData: [OptionSectionType] = [.currentDate, .scrollableRangeStart, .scrollableRangeEnd]
        if noIndexData.contains(data.subject) {
            pickerView.isHidden = true
            datePicker.isHidden = false
            datePicker.setDate(pickerData.selectedValue as? Date ?? Date(), animated: false)
        } else {
            pickerView.isHidden = false
            datePicker.isHidden = true
            pickerView.selectRow(pickerData.selectedIndex, inComponent: 0, animated: false)
            pickerView.reloadAllComponents()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    @objc func datePickerValueChanged() {
        pickerData.selectedValue = datePicker.date
        delegate?.selectedValueChanged(section: section)
    }
}

extension OptionsTableViewCell: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData?.categories == nil ? 0 : pickerData.categories!.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData?.categories == nil ? "" : pickerData.categoriesStr[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerData.selectedValue = pickerData.categories![row]
        delegate?.selectedValueChanged(section: section)
    }
}
