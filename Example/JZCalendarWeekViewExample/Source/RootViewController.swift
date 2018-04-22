//
//  RootViewController.swift
//  JZCalendarViewExample
//
//  Created by Jeff Zhang on 3/4/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit
import JZCalendarWeekView

class RootViewController: UIViewController {
    
    @IBOutlet weak var calendarView: WeekView!
    
    let viewModel = RootViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBasic()
        setupCalendarView()
        setupNaviBar()
    }
    
    func setupBasic() {
        //Add this to fix lower than iOS11 problems
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        calendarView.refreshWeekView()
    }
    
    private func setupCalendarView() {
        calendarView.setupCalendar(numOfDays: 3, setDate: Date(), allEvents: viewModel.eventsByDate)
    }
    
    private func setupNaviBar() {
        
        self.navigationItem.title = "Day View"
        let optionsButton = UIButton(type: .system)
        optionsButton.setImage(#imageLiteral(resourceName: "icon_options"), for: .normal)
        optionsButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        optionsButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        optionsButton.addTarget(self, action: #selector(presentOptionsVC), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: optionsButton)
    }
    
    @objc func presentOptionsVC() {
        let optionsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OptionsViewController") as! OptionsViewController
        let optionsViewModel = OptionsViewModel(selectedData: getSelectedData())
        optionsVC.viewModel = optionsViewModel
        optionsVC.delegate = self
        let navigationVC = UINavigationController(rootViewController: optionsVC)
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    private func getSelectedData() -> OptionsSelectedData {
        let numOfDays = calendarView.numOfDays!
        let firstDayOfWeek = numOfDays == 7 ? calendarView.firstDayOfWeek : nil
        return OptionsSelectedData(date: calendarView.initDate.add(component: .day, value: numOfDays),
                                   numOfDays: numOfDays,
                                   scrollType: calendarView.scrollType,
                                   firstDayOfWeek: firstDayOfWeek)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension RootViewController: OptionsViewDelegate {
    
    func finishUpdate(selectedData: OptionsSelectedData) {
        // Update numOfDays Only
        calendarView.numOfDays = selectedData.numOfDays
        calendarView.forceReload()
        // Update Date Only
        calendarView.updateWeekView(to: selectedData.date)
        // Update Scroll Type Only
        calendarView.scrollType = selectedData.scrollType
        // Update FirstDayOfWeek
        calendarView.updateFirstDayOfWeek(setDate: selectedData.date, firstDayOfWeek: selectedData.firstDayOfWeek)
    }
}

