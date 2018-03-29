//
//  BaseWeekView.swift
//  JZCalendarView
//
//  Created by Jeff Zhang on 28/3/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit

open class BaseWeekView: UIView {
    
    public typealias EventsByDate = [Date:[BaseEvent]]
    
    public var collectionView: UICollectionView!
    
    public var flowLayout: WeekViewFlowLayout!
    
    public var initDate: Date!
    
    public var numOfDays: Int!
    
    public var isOneDayScroll: Bool = false
    private var isFirstAppear: Bool = true
    
    var initialContentOffset = CGPoint.zero
    var scrollSections:CGFloat!
    
    var longPressType: LongPressType = .none
//    var longPressView: LongPressCellView! TODO
    var longPressView = UIView()
    private var isScrolling: Bool = false
    
    private var isDirectionLocked = false
    private var lockedDirection: ScrollDirection!
    
    
    public var allEventsBySection: EventsByDate!
    
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
    
    func setup() {
        
        flowLayout = WeekViewFlowLayout()
        flowLayout.delegate = self
        
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isDirectionalLockEnabled = true
        collectionView.bounces = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.white
        addSubview(collectionView)
        
        collectionView.setAnchorConstraintsFullSizeTo(view: self)
        
        registerViewClasses()
    }
    
    func registerViewClasses() {
        
        //supplementary
        collectionView.registerSupplimentaryViews([ColumnHeader.self, RowHeader.self, CornerHeader.self])
        
        //decoration
        flowLayout.registerDecorationViews([ColumnHeaderBackground.self, RowHeaderBackground.self, BaseCurrentTimeIndicator.self])
        flowLayout.register(GridLine.self, forDecorationViewOfKind: DecorationViewKinds.verticalGridline)
        flowLayout.register(GridLine.self, forDecorationViewOfKind: DecorationViewKinds.horizontalGridline)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        flowLayout.sectionWidth = (frame.width - flowLayout.rowHeaderWidth) / CGFloat(numOfDays)
        initialContentOffset = collectionView.contentOffset
    }
    
    func updateWeekView(to date: Date){
        
        self.initDate = date.add(component: .day, value: -numOfDays)
        DispatchQueue.main.async { [unowned self] in
            self.layoutSubviews()
            self.forceReload()
        }
    }
    
    //FirstOfWeek if nil, start from the setDate
    public func setupCalendar(numOfDays:Int, setDate:Date, firstDayOfWeek:DayOfWeek? = nil, allEvents: EventsByDate) {
        
        self.numOfDays = numOfDays
        
        if let firstDayOfWeek = firstDayOfWeek{
            let setDayOfWeek = setDate.getDayOfWeek()
            var diff = setDayOfWeek.rawValue - firstDayOfWeek.rawValue
            if diff < 0 {diff = 7 - abs(diff)}
            self.initDate = setDate.startOfDay.add(component: .day, value: -numOfDays - diff)
        }else{
            self.initDate = setDate.startOfDay.add(component: .day, value: -numOfDays)
        }
        
        DispatchQueue.main.async { [unowned self] in
            self.layoutSubviews()
            self.forceReload(reloadEvents: allEvents)
            
            if self.isFirstAppear {
                self.isFirstAppear = false
                self.flowLayout.scrollCollectionViewToCurrent()
            }
        }
    }
    
    
    public func forceReload(reloadEvents: [Date: [BaseEvent]]? = nil) {
        if let events = reloadEvents {
            self.allEventsBySection = events
        }
        
        // initial day is one page before the settle day
        collectionView.setContentOffset(CGPoint(x:frame.width - flowLayout.rowHeaderWidth, y:collectionView.contentOffset.y), animated: false)
        
        flowLayout.invalidateLayoutCache()
        collectionView.reloadData()
    }
    
    // Get date from points(Long press leftright Margin problem considered region before row header should be the following day)
    func getDateForX(xCollectionView: CGFloat, xSelfView: CGFloat) -> Date {
        
        let section = Int((xCollectionView - flowLayout.rowHeaderWidth) / flowLayout.sectionWidth)
        
        let date = Calendar.current.date(from: flowLayout.daysForSection(section))!
        
        //when isScrolling equals true, means it will scroll to previous date
        if xSelfView < flowLayout.rowHeaderWidth && isScrolling == false{
            return date.add(component: .day, value: 1)
        }else{
            return date
        }
        
    }
    
    func getDateForY(_ y: CGFloat) -> (Int, Int) {
        let adjustedY = y - flowLayout.columnHeaderHeight - flowLayout.contentsMargin.top - flowLayout.sectionMargin.top
        let hour = Int(adjustedY / flowLayout.hourHeight)
        let minute = Int((adjustedY / flowLayout.hourHeight - CGFloat(hour)) * 60)
        return (hour, minute)
    }
    
    func getDateForPoint(pointCollectionView: CGPoint, pointSelfView: CGPoint) -> Date{
        
        let yearMonthDay = getDateForX(xCollectionView: pointCollectionView.x, xSelfView: pointSelfView.x)
        let hourMinute = getDateForY(pointCollectionView.y)
        
        return Calendar.current.date(bySettingHour: hourMinute.0, minute: hourMinute.1, second: 0, of: yearMonthDay)!
    }
    
    // directionalLockEnabled
    fileprivate func determineScrollDirection() -> ScrollDirection {
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
    
    fileprivate func determineScrollDirectionAxis() -> ScrollDirection {
        let scrollDirection = determineScrollDirection()
        
        switch scrollDirection {
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


extension BaseWeekView: UICollectionViewDelegate, UICollectionViewDataSource{
    
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
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var view: UICollectionReusableView
        
        switch kind {
            
        case SupplementaryViewKinds.columnHeader:
            let columnHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as! ColumnHeader
            columnHeader.updateCell(date: flowLayout.dateForColumnHeader(at: indexPath))
            view = columnHeader
            
        case SupplementaryViewKinds.rowHeader:
            let rowHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as! RowHeader
            rowHeader.updateCell(date: flowLayout.dateForColumnHeader(at: indexPath))
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
        
        if determineScrollDirectionAxis() == .vertical {return}
        targetContentOffset.pointee = scrollView.contentOffset
        pagingEffect(scrollView: scrollView, velocity: velocity)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //for directionLock
        isDirectionLocked = false
    }
    
    // end dragging for loading drag to the leftmost and rightmost should load page
    // fast dragging missing scrollviewdidscroll for checking all day view
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        //for directionLock
        if !decelerate{
            isDirectionLocked = false
        }
        
        if determineScrollDirectionAxis() == .vertical {return}
        
        //loading page
        loadPage(scrollView: scrollView)
        
        if !isOneDayScroll {return}
    }
    
    //set content offset
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        //for directionLock
        isDirectionLocked = false
        
        if !isOneDayScroll{
            loadPage(scrollView: scrollView)
        }
        //changing initial date for one day scroll after paging effect
        if isOneDayScroll && scrollSections != 0{
            initDate = initDate.add(component: .day, value: -Int(scrollSections))
            self.forceReload()
        }
        //for long press
        isScrolling = false
        
    }
    
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if !isDirectionLocked{
            if abs(scrollView.contentOffset.x - initialContentOffset.x) > abs(scrollView.contentOffset.y - initialContentOffset.y){
                lockedDirection = .vertical
            }else{
                lockedDirection = .horizontal
            }
            isDirectionLocked = true
        }
        
        
        // forbid scrolling two directions together
        let scrollDirection = determineScrollDirectionAxis()
        var newOffset: CGPoint
        
        if scrollDirection == .crazy  {
            if lockedDirection == .vertical{
                newOffset = CGPoint(x: scrollView.contentOffset.x, y: initialContentOffset.y);
            } else {
                newOffset = CGPoint(x: initialContentOffset.x, y: scrollView.contentOffset.y);
            }
            scrollView.contentOffset = newOffset
        }
    }
    
    private func pagingEffect(scrollView: UIScrollView, velocity: CGPoint){
        
        let yCurrentOffset = scrollView.contentOffset.y
        let xCurrentOffset = scrollView.contentOffset.x
        let contentViewWidth = frame.width - flowLayout.rowHeaderWidth
        
        let scrollXDistance = initialContentOffset.x - xCurrentOffset
        //scroll one section
        if isOneDayScroll{
            let sectionWidth = flowLayout.sectionWidth!
            scrollSections = (scrollXDistance/sectionWidth).rounded()
            scrollView.setContentOffset(CGPoint(x:initialContentOffset.x-sectionWidth * scrollSections,y:yCurrentOffset), animated: true)
            
        }else{
            let scrollProportion:CGFloat = 1/5
            let isVelocitySatisfied = abs(velocity.x) > 0.2
            //scroll a whole page
            if scrollXDistance >= 0{
                if scrollXDistance >= scrollProportion * contentViewWidth || isVelocitySatisfied{
                    scrollView.setContentOffset(CGPoint(x:initialContentOffset.x-contentViewWidth,y:yCurrentOffset), animated: true)
                }else{
                    scrollView.setContentOffset(initialContentOffset, animated: true)
                }
            }else{
                if -scrollXDistance >= scrollProportion * contentViewWidth || isVelocitySatisfied{
                    scrollView.setContentOffset(CGPoint(x:initialContentOffset.x+contentViewWidth,y:yCurrentOffset), animated: true)
                }else{
                    scrollView.setContentOffset(initialContentOffset, animated: true)
                }
            }
        }
    }
    //for loading next page or previous only
    private func loadPage(scrollView: UIScrollView){
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
    
    @objc func loadNextOrPrevPage(isNext: Bool) {
        
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
    
    //only used in timeslot(overrided in timeslotWeekView)
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
    
    
    func updateTimeLabel(time: Date, point: CGPoint){
        
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
    
    
    
    
    func updateScroll(point: CGPoint){
        
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
        if Date.daysBetween(start: date, end: dateInSection) == 1 {
            //Below the bottom set as the following day
            startDate = date.startOfDay
        } else if Date.daysBetween(start: date, end: dateInSection) == -1 {
             //Beyond the top set as the current day
            startDate = dateInSection.startOfDay
        } else {
            let currentMin = Calendar.current.component(.minute, from: date)
            //Choose previous time interval (currentMin/timeMinInterval = Int)
            startDate = Calendar.current.date(bySetting: .minute, value: currentMin/timeMinInterval*timeMinInterval, of: date)!
        }
        
        return startDate
    }
    
    
    func scrollingTo(direction: ScrollDirection){
        
        let currentOffset = collectionView.contentOffset
        let maxOffsetY = collectionView.contentSize.height - collectionView.bounds.height + collectionView.contentInset.bottom
        
        if direction == .up || direction == .down{
            
            var yOffset = CGFloat()
            
            if isOneDayScroll{
                scrollSections = 0
            }
            
            if direction == .up{
                yOffset = max(0,currentOffset.y - 50)
                collectionView.setContentOffset(CGPoint(x: currentOffset.x,y: yOffset) , animated: true)
            }else{
                yOffset = min(maxOffsetY,currentOffset.y + 50)
                collectionView.setContentOffset(CGPoint(x: currentOffset.x,y: yOffset) , animated: true)
            }
            //scrollview didEndAnimation will not set isScrolling, should set by ourselves
            if yOffset == 0 || yOffset == maxOffsetY{
                isScrolling = false
            }
            
        }else{
            
            if isOneDayScroll{
                
                let sectionWidth = flowLayout.sectionWidth!
                
                if direction == .left{
                    scrollSections = -1
                }else{
                    scrollSections = 1
                }
                collectionView.setContentOffset(CGPoint(x:currentOffset.x-sectionWidth * scrollSections,y:currentOffset.y), animated: true)
                
            }else{
                let contentViewWidth = frame.width - flowLayout.rowHeaderWidth
                if direction == .left{
                    collectionView.setContentOffset(CGPoint(x:contentViewWidth * 2,y:currentOffset.y), animated: true)
                }else{
                    collectionView.setContentOffset(CGPoint(x:0,y:currentOffset.y), animated: true)
                }
            }
        }
        //must set initial contentoffset because will begin dragging will not be called
        initialContentOffset = collectionView.contentOffset
    }
    
}


