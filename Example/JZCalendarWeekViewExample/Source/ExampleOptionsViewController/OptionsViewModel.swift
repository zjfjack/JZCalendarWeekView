//
//  OptionsViewModel.swift
//  JZCalendarViewExample
//
//  Created by Jeff Zhang on 12/4/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit
import JZCalendarWeekView

class ExpandableData {
    
    var subject: OptionSectionType
    var categories: [Any]?
    lazy var categoriesStr: [String] = getCategoriesInString()
    var isExpanded: Bool = false
    var selectedValue: Any!
    
    var selectedIndex: Int {
        get {
            guard let cate = categories else { fatalError() }
            switch subject {
            case .viewType: return cate.index(where: {$0 as! ViewType == selectedValue as! ViewType})!
            case .numOfDays: return cate.index(where: {$0 as! Int == selectedValue as! Int})!
            case .scrollType: return cate.index(where: {$0 as! JZScrollType == selectedValue as! JZScrollType})!
            case .firstDayOfWeek: return cate.index(where: {$0 as! DayOfWeek == selectedValue as! DayOfWeek})!
            case .hourGridDivision: return cate.index(where: {$0 as! JZHourGridDivision == selectedValue as! JZHourGridDivision})!
            default:
                return 0
            }
        }
    }
    
    init(subject: OptionSectionType, categories: [Any]?=nil) {
        self.subject = subject
        self.categories = categories
    }
    
    func getCategoriesInString() -> [String] {
        guard let cate = categories else { return [] }
        switch subject {
        case .viewType: return cate.map { ($0 as! ViewType).rawValue }
        case .numOfDays: return cate.map { ($0 as! Int).description }
        case .scrollType: return cate.map { ($0 as! JZScrollType).displayText }
        case .firstDayOfWeek: return cate.map { ($0 as! DayOfWeek).dayName }
        case .hourGridDivision: return cate.map { ($0 as! JZHourGridDivision).displayText }
        default:
            return []
        }
    }
}

enum ViewType: String {
    case defaultView = "Default JZBaseWeekView"
    case customView = "Custom JZBaseWeekView"
    case longPressView = "JZLongPressWeekView"
}

enum OptionSectionType: String {
    case viewType = "View Type"
    case currentDate = "Current Date"
    case numOfDays = "Number Of Days"
    case scrollType = "Scroll Type"
    case firstDayOfWeek = "First Day Of Week"
    case hourGridDivision = "Hour Grid Division"
}

struct OptionsSelectedData {
    
    var viewType: ViewType
    var date: Date
    var numOfDays: Int
    var scrollType: JZScrollType
    var firstDayOfWeek: DayOfWeek?
    var hourGridDivision: JZHourGridDivision
    
    init(viewType: ViewType, date: Date, numOfDays: Int, scrollType: JZScrollType, firstDayOfWeek: DayOfWeek?, hourGridDivision: JZHourGridDivision) {
        self.viewType = viewType
        self.date = date
        self.numOfDays = numOfDays
        self.scrollType = scrollType
        self.firstDayOfWeek = firstDayOfWeek
        self.hourGridDivision = hourGridDivision
    }
}

class OptionsViewModel: NSObject {
    
    let dateFormatter = DateFormatter()
    var optionsData: [ExpandableData] = {
        let hourDivisionCategories: [JZHourGridDivision] = [.noneDiv, .minutes_5, .minutes_10, .minutes_15, .minutes_20, .minutes_30]
        let viewTypeCategories: [ViewType] = [.defaultView, .customView, .longPressView]
        return [
            ExpandableData(subject: .viewType, categories: viewTypeCategories),
            ExpandableData(subject: .currentDate),
            ExpandableData(subject: .numOfDays, categories: Array(1...10)),
            ExpandableData(subject: .scrollType, categories: [JZScrollType.pageScroll, JZScrollType.sectionScroll]),
            ExpandableData(subject: .hourGridDivision, categories: hourDivisionCategories)
        ]
    }()
    let perviousSelectedData: OptionsSelectedData
    
    init(selectedData: OptionsSelectedData) {
        self.perviousSelectedData = selectedData
        super.init()
        
        optionsData[0].selectedValue = selectedData.viewType
        optionsData[1].selectedValue = selectedData.date
        optionsData[2].selectedValue = selectedData.numOfDays
        optionsData[3].selectedValue = selectedData.scrollType
        optionsData[4].selectedValue = selectedData.hourGridDivision
        if let selectedDayOfWeek = selectedData.firstDayOfWeek {
            self.insertDayOfWeekToData(firstDayOfWeek: selectedDayOfWeek)
        }
        dateFormatter.dateFormat = "YYYY-MM-dd"
    }
    
    func getHeaderViewSubtitle(_ section: Int) -> String {
        let data = optionsData[section]
        
        switch data.subject {
        case .viewType:
            return (data.selectedValue! as! ViewType).rawValue
        case .currentDate:
            return dateFormatter.string(from: (data.selectedValue as! Date))
        case .numOfDays:
            return (data.selectedValue! as! Int).description
        case .scrollType:
            return (data.selectedValue! as! JZScrollType).displayText
        case .firstDayOfWeek:
            return (data.selectedValue! as! DayOfWeek).dayName
        case .hourGridDivision:
            return (data.selectedValue! as! JZHourGridDivision).displayText
        }
    }
    
    func insertDayOfWeekToData(firstDayOfWeek: DayOfWeek) {
        let dayOfWeekData = ExpandableData(subject: .firstDayOfWeek, categories: DayOfWeek.dayOfWeekList)
        dayOfWeekData.selectedValue = firstDayOfWeek
        optionsData.insert(dayOfWeekData, at: 3)
    }
    
    func removeDayOfWeekInData() {
        if optionsData[3].subject == .firstDayOfWeek {
            optionsData.remove(at: 3)
        }
    }
}
