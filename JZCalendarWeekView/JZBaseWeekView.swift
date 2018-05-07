//
//  JZBaseWeekView.swift
//  JZCalendarWeekView
//
//  Created by Jeff Zhang on 28/3/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

public protocol JZBaseViewDelegate: class {
    
    /// When initDate changed, this function will be called. You can get the current date by adding numOfDays on initDate
    ///
    /// - Parameters:
    ///   - weekView: current JZBaseWeekView
    ///   - initDate: the new value of initDate
    func initDateDidChange(_ weekView: JZBaseWeekView, initDate: Date)
}

extension JZBaseViewDelegate {
    // Keep it optional
    func initDateDidChange(_ weekView: JZBaseWeekView, initDate: Date) {}
}

open class JZBaseWeekView: UIView {
    
    public var collectionView: UICollectionView!
    public var flowLayout: JZWeekViewFlowLayout!
    
    /// The initial date of current collectionView. When page is not scrolling, the inital date is always
    /// the numOfDays days eariler than current page first date, which means the start of the collectionView.
    /// The core structure of JZCalendarWeekView is 3 pages, previous-current-next
    public var initDate: Date! {
        didSet {
            baseDelegate?.initDateDidChange(self, initDate: initDate)
        }
    }
    public var numOfDays: Int!
    public var scrollType: JZScrollType!
    public var firstDayOfWeek: DayOfWeek?
    public var allEventsBySection: EventsByDate!
    public weak var baseDelegate: JZBaseViewDelegate?
    open var contentViewWidth: CGFloat {
        return frame.width - flowLayout.rowHeaderWidth
    }
    private var isFirstAppear: Bool = true
    internal var initialContentOffset = CGPoint.zero
    internal var scrollSections:CGFloat!
    
    private var isDirectionLocked = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
        
    open func setup() {
        
        flowLayout = JZWeekViewFlowLayout()
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
    
    /// Override this function to customise items, supplimentaryViews and decorationViews
    open func registerViewClasses() {
        
        //supplementary
        collectionView.registerSupplimentaryViews([JZColumnHeader.self, JZCornerHeader.self, JZRowHeader.self])
        
        //decoration
        flowLayout.registerDecorationViews([JZColumnHeaderBackground.self, JZRowHeaderBackground.self, JZCornerHeaderBackground.self, JZCurrentTimeIndicator.self])
        flowLayout.register(JZGridLine.self, forDecorationViewOfKind: JZDecorationViewKinds.verticalGridline)
        flowLayout.register(JZGridLine.self, forDecorationViewOfKind: JZDecorationViewKinds.horizontalGridline)
    }
   
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        flowLayout.sectionWidth = contentViewWidth / CGFloat(numOfDays)
        initialContentOffset = collectionView.contentOffset
    }
    
    /**
     Basic Setup method for JZCalendarWeekView,it **must** be called.
     
     - Parameters:
        - numOfDays: number of days in a page
        - setDate: the initial set date, the first date in current page except WeekView (numOfDays = 7)
        - allEvents: The dictionary of all the events for present. JZWeekViewHelper.getIntraEventsByDate can help transform the data
        - firstDayOfWeek: First day of a week, **only works when numOfDays is 7**. Default value is Sunday
        - scrollType: The horizontal scroll type for this view. Default value is pageScroll
    */
    open func setupCalendar(numOfDays:Int,
                            setDate:Date,
                            allEvents: EventsByDate,
                            scrollType: JZScrollType = .pageScroll,
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
    
    /// Update collectionViewLayout with custom flowLayout. For some other values like gridThickness and contentsMargin, please inherit from JZWeekViewFlowLayout to change the default value
    /// - Parameter flowLayout: Custom CalendarWeekView flowLayout
    open func updateFlowLayout(_ flowLayout: JZWeekViewFlowLayout) {
        self.flowLayout.hourHeight = flowLayout.hourHeight
        self.flowLayout.rowHeaderWidth = flowLayout.rowHeaderWidth
        self.flowLayout.columnHeaderHeight = flowLayout.columnHeaderHeight
        self.flowLayout.hourGridDivision = flowLayout.hourGridDivision
        self.flowLayout.invalidateLayoutCache()
        self.flowLayout.invalidateLayout()
    }
    
    /// Reload the collectionView and flowLayout
    /// - Parameters:
    ///   - reloadEvents: If provided new events, current events will be reloaded. Default value is nil.
    public func forceReload(reloadEvents: [Date: [JZBaseEvent]]? = nil) {
        if let events = reloadEvents {
            self.allEventsBySection = events
        }
        
        // initial day is one page before the settle day
        collectionView.setContentOffset(CGPoint(x:contentViewWidth, y:collectionView.contentOffset.y), animated: false)
        
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
    
    /// Get current event with item indexPath
    ///
    /// - Parameter indexPath: The indexPath of an item in collectionView
    open func getCurrentEvent(with indexPath: IndexPath) -> JZBaseEvent? {
        let date = flowLayout.dateForColumnHeader(at: indexPath)
        return allEventsBySection[date]?[indexPath.row]
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
        self.forceReload()
    }

    
    /**
     Get date excluding time from points
        - Parameters:
            - xCollectionView: x position in collectionView
            - xSelfView: x position in current view (self)
     */
    open func getDateForX(xCollectionView: CGFloat, xSelfView: CGFloat) -> Date {
        let section = Int((xCollectionView - flowLayout.rowHeaderWidth) / flowLayout.sectionWidth)
        let date = Calendar.current.date(from: flowLayout.daysForSection(section))!
        return date
    }
    
    /// Get time from point y position
    /// - Parameters:
    ///    - yCollectionView: y position in collectionView
    open func getDateForY(yCollectionView: CGFloat) -> (Int, Int) {
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
        
        return yearMonthDay.set(hour: hourMinute.0, minute: hourMinute.1, second: 0)
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


extension JZBaseWeekView: UICollectionViewDelegate, UICollectionViewDataSource {
    
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
    
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view: UICollectionReusableView
        
        switch kind {
            
        case JZSupplementaryViewKinds.columnHeader:
            let columnHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as! JZColumnHeader
            columnHeader.updateView(date: flowLayout.dateForColumnHeader(at: indexPath))
            view = columnHeader
            
        case JZSupplementaryViewKinds.rowHeader:
            let rowHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as! JZRowHeader
            rowHeader.updateView(date: flowLayout.dateForTimeRowHeader(at: indexPath))
            view = rowHeader
            
        case JZSupplementaryViewKinds.cornerHeader:
            let cornerHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as! JZCornerHeader
            view = cornerHeader
            
        default:
            view = UICollectionReusableView()
        }
        return view
    }
    
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        initialContentOffset = scrollView.contentOffset
    }
    
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollDirectionAxis == .vertical { return }
        targetContentOffset.pointee = scrollView.contentOffset
        pagingEffect(scrollView: scrollView, velocity: velocity)
    }
    
    // end dragging for loading drag to the leftmost and rightmost should load page
    // If put the checking process in scrollViewWillEndDragging, then it will not work well
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let isDraggedToEdge = scrollView.contentOffset.x == 0 || scrollView.contentOffset.x == contentViewWidth * 2
        guard scrollDirectionAxis != .vertical && isDraggedToEdge else { return }
        if !decelerate { isDirectionLocked = false }
        loadPage(scrollView)
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //for directionLock
        isDirectionLocked = false
    }
    
    // This function will be called by setting content offset (pagingEffect function)
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        //for directionLock
        isDirectionLocked = false
        
        if scrollType != .sectionScroll {
            loadPage(scrollView)
        }
        // changing initial date(loadPage) for one day scroll after paging effect
        if scrollType == .sectionScroll && scrollSections != 0 {
            initDate = initDate.add(component: .day, value: -Int(scrollSections))
            self.forceReload()
        }
    }
    
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        var lockedDirection: ScrollDirection!
        
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
    
    /// It is used for scroll paging effect, scrollTypes sectionScroll and pageScroll applied here
    private func pagingEffect(scrollView: UIScrollView, velocity: CGPoint) {
        
        let yCurrentOffset = scrollView.contentOffset.y
        let xCurrentOffset = scrollView.contentOffset.x
        
        let scrollXDistance = initialContentOffset.x - xCurrentOffset
        // scroll one section
        if scrollType == .sectionScroll {
            let sectionWidth = flowLayout.sectionWidth!
            scrollSections = (scrollXDistance/sectionWidth).rounded()
            scrollView.setContentOffset(CGPoint(x:initialContentOffset.x-sectionWidth * scrollSections,y:yCurrentOffset), animated: true)
        } else {
            // Only for pageScroll
            let scrollProportion:CGFloat = 1/5
            let isVelocitySatisfied = abs(velocity.x) > 0.2
            // scroll a whole page
            if scrollXDistance >= 0 {
                if scrollXDistance >= scrollProportion * contentViewWidth || isVelocitySatisfied {
                    scrollView.setContentOffset(CGPoint(x:initialContentOffset.x-contentViewWidth,y:yCurrentOffset), animated: true)
                }else{
                    scrollView.setContentOffset(initialContentOffset, animated: true)
                }
            } else {
                if -scrollXDistance >= scrollProportion * contentViewWidth || isVelocitySatisfied {
                    scrollView.setContentOffset(CGPoint(x:initialContentOffset.x+contentViewWidth,y:yCurrentOffset), animated: true)
                } else {
                    scrollView.setContentOffset(initialContentOffset, animated: true)
                }
            }
        }
    }
    
    /// For loading next page or previous page (Only three pages exist)
    private func loadPage(_ scrollView: UIScrollView) {
        let maximumOffset = scrollView.contentSize.width - scrollView.frame.width
        let currentOffset = scrollView.contentOffset.x
        
        if maximumOffset <= currentOffset {
            //load next page
            loadNextOrPrevPage(isNext: true)
        }
        if currentOffset <= 0 {
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

extension JZBaseWeekView: WeekViewFlowLayoutDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, layout: JZWeekViewFlowLayout, dayForSection section: Int) -> Date {
        let date = Calendar.current.date(byAdding: .day, value: section, to: initDate)
        return date!
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout: JZWeekViewFlowLayout, startTimeForItemAtIndexPath indexPath: IndexPath) -> Date {
        let date = flowLayout.dateForColumnHeader(at: indexPath)
        
        if let events = allEventsBySection[date] {
            let event = events[indexPath.item]
            return event.intraStartDate
        } else {
            fatalError("Cannot get events")
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout: JZWeekViewFlowLayout, endTimeForItemAtIndexPath indexPath: IndexPath) -> Date {
        let date = flowLayout.dateForColumnHeader(at: indexPath)
        
        if let events = allEventsBySection[date] {
            let event = events[indexPath.item]
            return event.intraEndDate
        } else {
            fatalError("Cannot get events")
        }
    }
    
    //TODO: Only used when multiple cell types are used and need different overlap rules => layoutItemsAttributes
    public func collectionView(_ collectionView: UICollectionView, layout: JZWeekViewFlowLayout, cellTypeForItemAtIndexPath indexPath: IndexPath) -> String {
        return JZSupplementaryViewKinds.eventCell
    }
}
