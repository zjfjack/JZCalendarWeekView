//
//  OptionsViewController.swift
//  JZCalendarViewExample
//
//  Created by Jeff Zhang on 6/4/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit
import JZCalendarWeekView

protocol OptionsViewDelegate: class {
    func finishUpdate(selectedData: OptionsSelectedData)
}

class OptionsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var viewModel: OptionsViewModel!
    weak var delegate: OptionsViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBasic()
        setupTableView()
    }
    
    func setupBasic() {
        view.backgroundColor = UIColor.white
        navigationItem.title = "Options"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onBtnDoneTapped))
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 60
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.sectionHeaderHeight = 44
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: OptionsTableViewCell.className, bundle: nil), forCellReuseIdentifier: OptionsTableViewCell.className)
        tableView.register(UINib(nibName: ExpandableHeaderView.className, bundle: nil), forHeaderFooterViewReuseIdentifier: ExpandableHeaderView.className)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func onBtnDoneTapped() {
        var scrollType: CalendarViewScrollType
        var firstDayOfWeek: DayOfWeek? = nil
        let dataList = viewModel.optionsData
        if dataList[1].selectedValue as! Int == 7 {
            firstDayOfWeek = dataList[2].selectedValue as? DayOfWeek
            scrollType = dataList[3].selectedValue as! CalendarViewScrollType
        } else {
            scrollType = dataList[2].selectedValue as! CalendarViewScrollType
        }
        
        delegate?.finishUpdate(selectedData: OptionsSelectedData(date: dataList[0].selectedValue as! Date,
                                                                 numOfDays: dataList[1].selectedValue as! Int,
                                                                 scrollType: scrollType,
                                                                 firstDayOfWeek: firstDayOfWeek))
        self.dismiss(animated: true, completion: nil)
    }
}

extension OptionsViewController: UITableViewDelegate, UITableViewDataSource, ExpandableHeaderViewDelegate, OptionsCellDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.optionsData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.optionsData[indexPath.section].isExpanded ? UITableViewAutomaticDimension : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OptionsTableViewCell.className, for: indexPath) as! OptionsTableViewCell
        cell.updateCell(data: viewModel.optionsData[indexPath.section], section: indexPath.section)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ExpandableHeaderView.className) as! ExpandableHeaderView
        headerView.updateHeaderView(section: section, title: viewModel.optionsData[section].subject.rawValue, subTitle: viewModel.getHeaderViewSubtitle(section))
        headerView.delegate = self
        return headerView
    }
    
    func toggleSection(section: Int) {
        viewModel.optionsData[section].isExpanded = !viewModel.optionsData[section].isExpanded
        tableView.beginUpdates()
        tableView.reloadRows(at: [IndexPath(row: 0, section: section)], with: .automatic)
        tableView.endUpdates()
    }
    
    func selectedValueChanged(section: Int) {
        let headerView = tableView.headerView(forSection: section) as! ExpandableHeaderView
        headerView.lblSelectedValue.text = viewModel.getHeaderViewSubtitle(section)
        
        if section == 1 {
            if viewModel.optionsData[1].selectedIndex == 6 && viewModel.optionsData[2].subject != .firstDayOfWeek {
                viewModel.insertDayOfWeekToData(firstDayOfWeek: .sunday)
                tableView.reloadData()
            }
            if viewModel.optionsData[1].selectedIndex != 6 && viewModel.optionsData[2].subject == .firstDayOfWeek {
                viewModel.removeDayOfWeekInData()
                tableView.reloadData()
            }
        }
    }
}
