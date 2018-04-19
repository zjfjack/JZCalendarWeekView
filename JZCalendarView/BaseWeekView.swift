//
//  BaseWeekView.swift
//  JZCalendarView
//
//  Created by Jeff Zhang on 28/3/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit

open class BaseWeekView: UIView {
    
    public var collectionView: UICollectionView!
    public var flowLayout: WeekViewFlowLayout!
    
    public var initDate: Date!
    public var numOfDays: Int!
    public var scrollType: CalendarViewScrollType!
    public var firstDayOfWeek: DayOfWeek?
    public var allEventsBySection: EventsByDate!
    
    private var isFirstAppear: Bool = true
    private var initialContentOffset = CGPoint.zero
    private var scrollSections:CGFloat!
    
    var longPressType: LongPressType = .none
//    var longPressView: LongPressCellView! TODO
    var longPressView = UIView()
    private var isScrolling: Bool = false
    private var isDirectionLocked = false
    private var lockedDirection: ScrollDirection!
    
    enum LongPressType {
        case none
        case addNew
        case move
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
        
    open func setup() {
        
        flowLayout = WeekViewFlowLayout()
        flowLayout.delegate = self
        
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isDirectionalLockEnabled = true
        collectionView.bounces = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.white
        addSubview(collectionView)
        collectionView.setAnchorConstraintsFullSizeTo(view: self)
        
        registerViewClasses()
    }
    
    open func registerViewClasses() {
        
        //supplementary
        collectionView.registerSupplimentaryViews([ColumnHeader.self, CornerHeader.self, RowHeader.self])
        
        //decoration
        flowLayout.registerDecorationViews([ColumnHeaderBackground.self, RowHeaderBackground.self, CurrentTimeIndicator.self])
        flowLayout.register(GridLine.self, forDecorationViewOfKind: DecorationViewKinds.verticalGridline)
        flowLayout.register(GridLine.self, forDecorationViewOfKind: DecorationViewKinds.horizontalGridline)
    }
   
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        flowLayout.sectionWidth = (frame.width - flowLayout.rowHeaderWidth) / CGFloat(numOfDays)
        initialContentOffset = collectionView.contentOffset
    }
    
    /**
     Basic Setup method for JZCalendarView,it **must** be called.
     
     - Parameters:
        - numOfDays: number of days in a page
        - setDate: the initial set date
        - allEvents: The dictionary of all the events for present. WeekViewHelper.getIntraEventsByDate can help transform the data
        - firstDayOfWeek: First day of a week, only works when numberOfDays is 7. Default value is nil, and the first day shown is the setDate
        - scrollType: The horizontal scroll type for this view. Default value is pageScroll
    */
    open func setupCalendar(numOfDays:Int,
                            setDate:Date,
                            allEvents: EventsByDate,
                            scrollType: CalendarViewScrollType = .pageScroll,
                            firstDayOfWeek:DayOfWeek? = nil) {
        
        self.numOfDays = numOfDays
        self.allEventsBySection = allEvents
        self.scrollType = scrollType
        
        if numOfDays == 7 {
            updateFirstDayOfWeek(setDate: setDate, firstDayOfWeek: firstDayOfWeek ?? .sunday)
        } else {
            self.initDate = setDate.startOfDay.add(component: .day, value: -numOfDays)
        }
        
        DispatchQueue.main.async { [unowned self] in
            self.layoutSubviews()
            self.forceReload(reloadEvents: allEvents)
            
            if self.isFirstAppear {
                self.isFirstAppear = false
                self.flowLayout.scrollCollectionViewToCurrentTime()
            }
        }
    }
    
    /// Reload the collectionView and flowLayout
    /// - Parameters:
    ///   - reloadEvents: If provided new events, current events will be reloaded. Default value is nil.
    public func forceReload(reloadEvents: [Date: [BaseEvent]]? = nil) {
        if let events = reloadEvents {
            self.allEventsBySection = events
        }
        
        // initial day is one page before the settle day
        collectionView.setContentOffset(CGPoint(x:frame.width - flowLayout.rowHeaderWidth, y:collectionView.contentOffset.y), animated: false)
        
        flowLayout.invalidateLayoutCache()
        collectionView.reloadData()
    }
        
    
    /// Reload the WeekView to date with no animation
    /// - Parameters:
    ///    - date: this date is the current date in one-day view rather than initDate
    open func updateWeekView(to date: Date) {
        self.initDate = date.add(component: .day, value: -numOfDays)
        DispatchQueue.main.async { [unowned self] in
            self.layoutSubviews()
            self.forceReload()
        }
    }
    
    /**
        Used to Refresh the weekView when viewWillTransition
     
        **Must override viewWillTransition in the ViewController and call this function**
    */
    open func refreshWeekView() {
        updateWeekView(to: self.initDate.add(component: .day, value: numOfDays))
    }
    
    open func updateFirstDayOfWeek(setDate: Date, firstDayOfWeek: DayOfWeek?) {
        guard let firstDayOfWeek = firstDayOfWeek, numOfDays == 7 else { return }
        let setDayOfWeek = setDate.getDayOfWeek()
        var diff = setDayOfWeek.rawValue - firstDayOfWeek.rawValue
        if diff < 0 { diff = 7 - abs(diff) }
        self.initDate = setDate.startOfDay.add(component: .day, value: -numOfDays - diff)
        self.firstDayOfWeek = firstDayOfWeek
    }

    
    /**
     Get date from points(Long press leftright Margin problem considered region before row header should be the following day)
        - Parameters:
            - xCollectionView: x position in collectionView
            - xSelfView: x position in current view (self)
     */
    private func getDateForX(xCollectionView: CGFloat, xSelfView: CGFloat) -> Date {
        
        let section = Int((xCollectionView - flowLayout.rowHeaderWidth) / flowLayout.sectionWidth)
        
        let date = Calendar.current.date(from: flowLayout.daysForSection(section))!
        
        //when isScrolling equals true, means it will scroll to previous date
        if xSelfView < flowLayout.rowHeaderWidth && isScrolling == false{
            return date.add(component: .day, value: 1)
        }else{
            return date
        }
        
    }
    
    /// Get time from point y position
    /// - Parameters:
    ///    - yCollectionView: y position in collectionView
    private func getDateForY(yCollectionView: CGFloat) -> (Int, Int) {
        let adjustedY = yCollectionView - flowLayout.columnHeaderHeight - flowLayout.contentsMargin.top - flowLayout.sectionMargin.top
        let hour = Int(adjustedY / flowLayout.hourHeight)
        let minute = Int((adjustedY / flowLayout.hourHeight - CGFloat(hour)) * 60)
        return (hour, minute)
    }
    
    /**
     Get date from current point, can be used for gesture recognizer
        - Parameters:
            - pointCollectionView: current point position in collectionView
            - pointSelfView: current point in current view (self)
     */
    public func getDateForPoint(pointCollectionView: CGPoint, pointSelfView: CGPoint) -> Date {
        
        let yearMonthDay = getDateForX(xCollectionView: pointCollectionView.x, xSelfView: pointSelfView.x)
        let hourMinute = getDateForY(yCollectionView: pointCollectionView.y)
        
        return Calendar.current.date(bySettingHour: hourMinute.0, minute: hourMinute.1, second: 0, of: yearMonthDay)!
    }
    
    /// Get weekview scroll direction (directionalLockEnabled)
    fileprivate func getScrollDirection() -> ScrollDirection {
        var scrollDirection: ScrollDirection
        
        if initialContentOffset.x != collectionView.contentOffset.x &&
            initialContentOffset.y != collectionView.contentOffset.y {
            scrollDirection = .crazy
        } else {
            if initialContentOffset.x > collectionView.contentOffset.x {
                scrollDirection = .left
            } else if initialContentOffset.x < collectionView.contentOffset.x {
                scrollDirection = .right
            } else if initialContentOffset.y > collectionView.contentOffset.y {
                scrollDirection = .up
            } else if initialContentOffset.y < collectionView.contentOffset.y {
                scrollDirection = .down
            } else {
                scrollDirection = .none
            }
        }
        return scrollDirection
    }
    
    /// Get scroll direction axis
    fileprivate var scrollDirectionAxis: ScrollDirection {
        switch getScrollDirection() {
        case .left, .right:
            return .horizontal
        case .up, .down:
            return .vertical
        case .crazy:
            return .crazy
        default:
            return .none
        }
    }
    
}


extension BaseWeekView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // In order to keep efficiency, only 3 pages exist at the same time, previous-current-next
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3 * numOfDays
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let date = flowLayout.dateForColumnHeader(at: IndexPath(item: 0, section: section))
        
        if let events = allEventsBySection[date] {
            return events.count
        } else {
            return 0
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        preconditionFailure("This method must be overridden")
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view: UICollectionReusableView
        
        switch kind {
            
        case SupplementaryViewKinds.columnHeader:
            let columnHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as! ColumnHeader
            columnHeader.updateCell(date: flowLayout.dateForColumnHeader(at: indexPath))
            view = columnHeader
            
        case SupplementaryViewKinds.rowHeader:
            let rowHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as! RowHeader
            rowHeader.updateCell(date: flowLayout.dateForTimeRowHeader(at: indexPath))
            view = rowHeader
            
        case SupplementaryViewKinds.cornerHeader:
            let cornerHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as! CornerHeader
            view = cornerHeader
            
        default:
            view = UICollectionReusableView()
        }
        
        return view
    }
    
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        initialContentOffset = scrollView.contentOffset
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if scrollDirectionAxis == .vertical {return}
        targetContentOffset.pointee = scrollView.contentOffset
        pagingEffect(scrollView: scrollView, velocity: velocity)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //for directionLock
        isDirectionLocked = false
    }
    
    // end dragging for loading drag to the leftmost and rightmost should load page
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        //for directionLock
        if !decelerate {
            isDirectionLocked = false
        }
        if scrollDirectionAxis == .vertical {return}
        loadPage(scrollView: scrollView)
    }
    
    //set content offset
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        //for directionLock
        isDirectionLocked = false
        
        if scrollType != .sectionScroll {
            loadPage(scrollView: scrollView)
        }
        //changing initial date(loadPage) for one day scroll after paging effect
        if scrollType == .sectionScroll && scrollSections != 0 {
            initDate = initDate.add(component: .day, value: -Int(scrollSections))
            self.forceReload()
        }
        //for long press
        isScrolling = false
    }
    
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if !isDirectionLocked {
            let isScrollingHorizontally = abs(scrollView.contentOffset.x - initialContentOffset.x) > abs(scrollView.contentOffset.y - initialContentOffset.y)
            lockedDirection = isScrollingHorizontally ? .vertical : .horizontal
            isDirectionLocked = true
        }
        
        // forbid scrolling two directions together
        if scrollDirectionAxis == .crazy {
            let newOffset = lockedDirection == .vertical ? CGPoint(x: scrollView.contentOffset.x, y: initialContentOffset.y) :
                                                           CGPoint(x: initialContentOffset.x, y: scrollView.contentOffset.y)
            scrollView.contentOffset = newOffset
        }
    }
    
    ///It is used for scroll paging effect, scrollTypes sectionScroll and pageScroll applied here
    private func pagingEffect(scrollView: UIScrollView, velocity: CGPoint) {
        
        let yCurrentOffset = scrollView.contentOffset.y
        let xCurrentOffset = scrollView.contentOffset.x
        let contentViewWidth = frame.width - flowLayout.rowHeaderWidth
        
        let scrollXDistance = initialContentOffset.x - xCurrentOffset
        //scroll one section
        if scrollType == .sectionScroll {
            let sectionWidth = flowLayout.sectionWidth!
            scrollSections = (scrollXDistance/sectionWidth).rounded()
            scrollView.setContentOffset(CGPoint(x:initialContentOffset.x-sectionWidth * scrollSections,y:yCurrentOffset), animated: true)
        } else {
            //Only for pageScroll
            let scrollProportion:CGFloat = 1/5
            let isVelocitySatisfied = abs(velocity.x) > 0.2
            //scroll a whole page
            if scrollXDistance >= 0 {
                if scrollXDistance >= scrollProportion * contentViewWidth || isVelocitySatisfied {
                    scrollView.setContentOffset(CGPoint(x:initialContentOffset.x-contentViewWidth,y:yCurrentOffset), animated: true)
                }else{
                    scrollView.setContentOffset(initialContentOffset, animated: true)
                }
            }else{
                if -scrollXDistance >= scrollProportion * contentViewWidth || isVelocitySatisfied {
                    scrollView.setContentOffset(CGPoint(x:initialContentOffset.x+contentViewWidth,y:yCurrentOffset), animated: true)
                }else{
                    scrollView.setContentOffset(initialContentOffset, animated: true)
                }
            }
        }
    }
    
    ///For loading next page or previous page (Only three pages exist)
    private func loadPage(scrollView: UIScrollView) {
        let maximumOffset = scrollView.contentSize.width - scrollView.frame.width
        let currentOffset = scrollView.contentOffset.x
        
        if maximumOffset <= currentOffset{
            //load next page
            loadNextOrPrevPage(isNext: true)
        }
        if currentOffset <= 0{
            //load previous page
            loadNextOrPrevPage(isNext: false)
        }
    }
    
    ///Can be overrided to do some operations before reload
    open func loadNextOrPrevPage(isNext: Bool) {
        let addValue = isNext ? numOfDays : -numOfDays
        self.initDate = self.initDate.add(component: .day, value: addValue!)
        self.forceReload()
    }
}

extension BaseWeekView: WeekViewFlowLayoutDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, layout: WeekViewFlowLayout, dayForSection section: Int) -> Date {
        let date = Calendar.current.date(byAdding: .day, value: section, to: initDate)
        return date!
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout: WeekViewFlowLayout, startTimeForItemAtIndexPath indexPath: IndexPath) -> Date {
        let date = flowLayout.dateForColumnHeader(at: indexPath)
        
        if let events = allEventsBySection[date] {
            let event = events[indexPath.item]
            return event.intraStartDate
        } else {
            fatalError("Cannot get events")
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout: WeekViewFlowLayout, endTimeForItemAtIndexPath indexPath: IndexPath) -> Date {
        let date = flowLayout.dateForColumnHeader(at: indexPath)
        
        if let events = allEventsBySection[date] {
            let event = events[indexPath.item]
            return event.intraEndDate
        } else {
            fatalError("Cannot get events")
        }
    }
    
    //TODO: Only used when multiple cell types are used and need different overlap rules => layoutItemsAttributes
    public func collectionView(_ collectionView: UICollectionView, layout: WeekViewFlowLayout, cellTypeForItemAtIndexPath indexPath: IndexPath) -> String {
        return BaseEventCell.className
    }
}

//Long press Gesture methods
extension BaseWeekView {
    
    
    @objc func getTopMarginY() -> CGFloat{
        
        preconditionFailure("This method must be overridden if using long press gesuture")
    }
    
    @objc func getBotMarginY() -> CGFloat{
        
        preconditionFailure("This method must be overridden if using long press gesuture")
    }
    
    
    func updateTimeLabel(time: Date, point: CGPoint) {
        
        let timeLabel = UILabel(frame: .zero)
//        let timeLabel = longPressView.timeLabel! TODO
        timeLabel.text = time.getTimeIgnoreSecondsFormat()
        
        if point.x - longPressView.frame.width/2 < flowLayout.rowHeaderWidth{
            timeLabel.textAlignment = .right
        }else{
            timeLabel.textAlignment = .left
        }
        
        let labelHeight = timeLabel.frame.height
        let minOriginY = getTopMarginY()
        
        if point.y - labelHeight < minOriginY{
            
            let rect = CGRect(x: 0, y: longPressView.frame.height, width: timeLabel.frame.width, height: labelHeight)
            
            if timeLabel.frame != rect{
                timeLabel.frame = rect
            }
            
        }else{
            
            let rect = CGRect(x: 0, y: -labelHeight, width: timeLabel.frame.width, height: labelHeight)
            
            if timeLabel.frame != rect{
                timeLabel.frame = rect
            }
        }
    }
    
    
    
    
    func updateScroll(point: CGPoint) {
        
        //vertical
        if point.y < getTopMarginY() + 10 && !isScrolling{
            isScrolling = true
            scrollingTo(direction: .up)
        }else if point.y > getBotMarginY() - 10 && !isScrolling{
            isScrolling = true
            scrollingTo(direction: .down)
        }
        
        //horizontal
        if point.x < flowLayout.rowHeaderWidth && !isScrolling{
            isScrolling = true
            scrollingTo(direction: .right)
            
        }else if frame.width - point.x < 20 && !isScrolling{
            isScrolling = true
            scrollingTo(direction: .left)
        }
    }
    
    //TimeMinInterval is to identify the minimum time interval(Minute) when scrolling (minimum value is 1)
    func getLongpressStartTime(date: Date, dateInSection: Date, timeMinInterval: Int) -> Date {
        
        let startDate: Date
        if Date.daysBetween(start: dateInSection, end: date) == 1 {
            //Below the bottom set as the following day
            startDate = date.startOfDay
        } else if Date.daysBetween(start: dateInSection, end: date) == -1 {
             //Beyond the top set as the current day
            startDate = dateInSection.startOfDay
        } else {
            let currentMin = Calendar.current.component(.minute, from: date)
            //Choose previous time interval (currentMin/timeMinInterval = Int)
            startDate = Calendar.current.date(bySetting: .minute, value: currentMin/timeMinInterval*timeMinInterval, of: date)!
        }
        
        return startDate
    }
    
    
    func scrollingTo(direction: ScrollDirection) {
        
        let currentOffset = collectionView.contentOffset
        let maxOffsetY = collectionView.contentSize.height - collectionView.bounds.height + collectionView.contentInset.bottom
        
        if direction == .up || direction == .down {
            
            var yOffset = CGFloat()
            
            //TODO: NOT SURE WHY NEED THIS LINE
            if scrollType == .sectionScroll {
                scrollSections = 0
            }
            
            if direction == .up {
                yOffset = max(0,currentOffset.y - 50)
                collectionView.setContentOffset(CGPoint(x: currentOffset.x,y: yOffset) , animated: true)
            } else {
                yOffset = min(maxOffsetY,currentOffset.y + 50)
                collectionView.setContentOffset(CGPoint(x: currentOffset.x,y: yOffset) , animated: true)
            }
            //scrollview didEndAnimation will not set isScrolling, should set by ourselves
            if yOffset == 0 || yOffset == maxOffsetY {
                isScrolling = false
            }
            
        } else {
            switch scrollType! {
            case .sectionScroll:
                let sectionWidth = flowLayout.sectionWidth!
                scrollSections = direction == .left ? -1 : 1
                collectionView.setContentOffset(CGPoint(x: currentOffset.x - sectionWidth * scrollSections, y: currentOffset.y), animated: true)
            case .pageScroll:
                let contentViewWidth = frame.width - flowLayout.rowHeaderWidth
                let contentOffsetX = direction == .left ? contentViewWidth * 2 : 0
                collectionView.setContentOffset(CGPoint(x: contentOffsetX, y: currentOffset.y), animated: true)
            }
        }
        //must set initial contentoffset because willBeginDragging will not be called
        initialContentOffset = collectionView.contentOffset
    }
    
}


