//
//  RootViewController.swift
//  JZCalendarViewExample
//
//  Created by Jeff Zhang on 3/4/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit
import JZCalendarView

class RootViewController: UIViewController {
    
    @IBOutlet weak var calendarView: JZWeekView!
    
    let viewModel = RootViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCalendarView()
        setupNaviBar()
    }
    
    private func setupCalendarView() {
        
        calendarView.setupCalendar(numOfDays: 1, setDate: Date(), allEvents: viewModel.eventsByDate)
    }
    
    private func setupNaviBar() {
        
        self.navigationItem.title = "Day View"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Options", style: .plain, target: self, action: #selector(presentOptionsVC))
    }
    
    @objc func presentOptionsVC() {
        let optionsVC = OptionsViewController()
        self.navigationController?.pushViewController(optionsVC, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

