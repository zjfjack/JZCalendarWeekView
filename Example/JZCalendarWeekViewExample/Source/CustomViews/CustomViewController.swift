//
//  CustomViewController.swift
//  JZCalendarWeekViewExample
//
//  Created by Jeff Zhang on 1/5/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit
import JZCalendarWeekView

// Except calendarWeekView type (CustomWeekView) is different from DefaultViewController, others are totally the same
class CustomViewController: UIViewController {

    @IBOutlet weak var calendarWeekView: CustomWeekView!

    let viewModel = DefaultViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBasic()
        setupCalendarView()
        setupNaviBar()
    }

    // Support device orientation change
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        JZWeekViewHelper.viewTransitionHandler(to: size, weekView: calendarWeekView)
    }

    private func setupCalendarView() {
        calendarWeekView.baseDelegate = self

        if viewModel.currentSelectedData != nil {
            // For example only
            setupCalendarViewWithSelectedData()
        } else {
            // Normal setup with different visible time
            let time8AM = DateComponents(calendar: Calendar.current, timeZone: Calendar.current.timeZone, year: 2018, month: 9, day: 24, hour: 8, minute: 0, second: 0).date!
            calendarWeekView.setupCalendar(numOfDays: 3,
                                           setDate: Date(),
                                           allEvents: viewModel.eventsByDate,
                                           scrollType: .pageScroll,
                                           visibleTime: time8AM)
        }
    }

    /// For example only
    private func setupCalendarViewWithSelectedData() {
        guard let selectedData = viewModel.currentSelectedData else { return }

        let time8AM = DateComponents(calendar: Calendar.current, timeZone: Calendar.current.timeZone, year: 2018, month: 9, day: 24, hour: 8, minute: 0, second: 0).date!
        calendarWeekView.setupCalendar(numOfDays: selectedData.numOfDays,
                                       setDate: selectedData.date,
                                       allEvents: viewModel.eventsByDate,
                                       scrollType: selectedData.scrollType,
                                       firstDayOfWeek: selectedData.firstDayOfWeek,
                                       visibleTime: time8AM)
        calendarWeekView.updateFlowLayout(JZWeekViewFlowLayout(hourGridDivision: selectedData.hourGridDivision))
    }
}

extension CustomViewController: JZBaseViewDelegate {
    func initDateDidChange(_ weekView: JZBaseWeekView, initDate: Date) {
        updateNaviBarTitle()
    }
}

// For example only
extension CustomViewController: OptionsViewDelegate {

    func setupBasic() {
        // Add this to fix lower than iOS11 problems
        self.automaticallyAdjustsScrollViewInsets = false
    }

    private func setupNaviBar() {
        updateNaviBarTitle()
        let optionsButton = UIButton(type: .system)
        optionsButton.setImage(#imageLiteral(resourceName: "icon_options"), for: .normal)
        optionsButton.frame.size = CGSize(width: 25, height: 25)
        if #available(iOS 11.0, *) {
            optionsButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
            optionsButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        }
        optionsButton.addTarget(self, action: #selector(presentOptionsVC), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: optionsButton)
    }

    @objc func presentOptionsVC() {
        let optionsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OptionsViewController") as! ExampleOptionsViewController
        let optionsViewModel = OptionsViewModel(selectedData: getSelectedData())
        optionsVC.viewModel = optionsViewModel
        optionsVC.delegate = self
        let navigationVC = UINavigationController(rootViewController: optionsVC)
        self.present(navigationVC, animated: true, completion: nil)
    }

    private func getSelectedData() -> OptionsSelectedData {
        let numOfDays = calendarWeekView.numOfDays!
        let firstDayOfWeek = numOfDays == 7 ? calendarWeekView.firstDayOfWeek : nil
        viewModel.currentSelectedData = OptionsSelectedData(viewType: .customView,
                                                            date: calendarWeekView.initDate.add(component: .day, value: numOfDays),
                                                            numOfDays: numOfDays,
                                                            scrollType: calendarWeekView.scrollType,
                                                            firstDayOfWeek: firstDayOfWeek,
                                                            hourGridDivision: calendarWeekView.flowLayout.hourGridDivision,
                                                            scrollableRange: calendarWeekView.scrollableRange)
        return viewModel.currentSelectedData
    }

    func finishUpdate(selectedData: OptionsSelectedData) {

        // Update numOfDays
        if selectedData.numOfDays != viewModel.currentSelectedData.numOfDays {
            calendarWeekView.numOfDays = selectedData.numOfDays
            calendarWeekView.refreshWeekView()
        }
        // Update Date
        if selectedData.date != viewModel.currentSelectedData.date {
            calendarWeekView.updateWeekView(to: selectedData.date)
        }
        // Update Scroll Type
        if selectedData.scrollType != viewModel.currentSelectedData.scrollType {
            calendarWeekView.scrollType = selectedData.scrollType
            // If you want to change the scrollType without forceReload, you should call setHorizontalEdgesOffsetX
            calendarWeekView.setHorizontalEdgesOffsetX()
        }
        // Update FirstDayOfWeek
        if selectedData.firstDayOfWeek != viewModel.currentSelectedData.firstDayOfWeek {
            calendarWeekView.updateFirstDayOfWeek(setDate: selectedData.date, firstDayOfWeek: selectedData.firstDayOfWeek)
        }
        // Update hourGridDivision
        if selectedData.hourGridDivision != viewModel.currentSelectedData.hourGridDivision {
            calendarWeekView.updateFlowLayout(JZWeekViewFlowLayout(hourGridDivision: selectedData.hourGridDivision))
        }
        // Update scrollableRange
        if selectedData.scrollableRange != viewModel.currentSelectedData.scrollableRange {
            calendarWeekView.scrollableRange = selectedData.scrollableRange
        }
    }

    private func updateNaviBarTitle() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM YYYY"
        self.navigationItem.title = dateFormatter.string(from: calendarWeekView.initDate.add(component: .day, value: calendarWeekView.numOfDays))
    }
}
