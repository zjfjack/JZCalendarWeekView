//
//  OptionsViewModel.swift
//  JZCalendarViewExample
//
//  Created by Jeff Zhang on 12/4/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit
import JZCalendarView

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
            case .numOfDays: return cate.index(where: {$0 as! Int == selectedValue as! Int})!
            case .scrollType: return cate.index(where: {$0 as! CalendarViewScrollType == selectedValue as! CalendarViewScrollType})!
            case .firstDayOfWeek: return cate.index(where: {$0 as! DayOfWeek == selectedValue as! DayOfWeek})!
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
        case .numOfDays: return cate.map { ($0 as! Int).description }
        case .scrollType: return cate.map { ($0 as! CalendarViewScrollType).rawValue }
        case .firstDayOfWeek: return cate.map { ($0 as! DayOfWeek).getDayName() }
        default:
            return []
        }
    }
}

enum OptionSectionType: String {
    case currentDate = "Current Date"
    case numOfDays = "Number Of Days"
    case scrollType = "Scroll Type"
    case firstDayOfWeek = "First Day Of Week"
}

struct OptionsSelectedData {
    
    var date: Date
    var numOfDays: Int
    var scrollType: CalendarViewScrollType
    var firstDayOfWeek: DayOfWeek?
    
    init(date: Date, numOfDays: Int, scrollType: CalendarViewScrollType, firstDayOfWeek: DayOfWeek?) {
        self.date = date
        self.numOfDays = numOfDays
        self.scrollType = scrollType
        self.firstDayOfWeek = firstDayOfWeek
    }
}

class OptionsViewModel: NSObject {
    
    let dateFormatter = DateFormatter()
    var optionsData: [ExpandableData] = [
        ExpandableData(subject: .currentDate),
        ExpandableData(subject: .numOfDays, categories: Array(1...10)),
        ExpandableData(subject: .scrollType, categories: [CalendarViewScrollType.pageScroll, CalendarViewScrollType.sectionScroll])
    ]
    
    init(selectedData: OptionsSelectedData) {
        super.init()
        optionsData[0].selectedValue = selectedData.date
        optionsData[1].selectedValue = selectedData.numOfDays
        optionsData[2].selectedValue = selectedData.scrollType
        if let selectedDayOfWeek = selectedData.firstDayOfWeek {
            self.insertDayOfWeekToData(firstDayOfWeek: selectedDayOfWeek)
        }
         dateFormatter.dateFormat = "YYYY-MM-dd"
    }
    
    func getHeaderViewSubtitle(_ section: Int) -> String {
        let data = optionsData[section]
        
        switch data.subject {
        case .currentDate:
            return dateFormatter.string(from: (data.selectedValue as! Date))
        case .numOfDays:
            return (data.selectedValue! as! Int).description
        case .scrollType:
            return (data.selectedValue! as! CalendarViewScrollType).rawValue
        case .firstDayOfWeek:
            return (data.selectedValue! as! DayOfWeek).getDayName()
        }
    }
    
    func insertDayOfWeekToData(firstDayOfWeek: DayOfWeek) {
        let dayOfWeekData = ExpandableData(subject: .firstDayOfWeek, categories: DayOfWeek.getDayOfWeekList())
        dayOfWeekData.selectedValue = firstDayOfWeek
        optionsData.insert(dayOfWeekData, at: 2)
    }
    
    func removeDayOfWeekInData() {
        if optionsData[2].subject == .firstDayOfWeek {
            optionsData.remove(at: 2)
        }
    }
}
