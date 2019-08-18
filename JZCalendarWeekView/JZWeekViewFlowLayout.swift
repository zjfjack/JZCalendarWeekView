//
//  JZWeekViewFlowLayout.swift
//  JZCalendarWeekView
//
//  Created by Jeff Zhang on 28/3/18.
//  Inspired and followed by WRCalendarView (https://github.com/wayfinders/WRCalendarView)
//

public protocol WeekViewFlowLayoutDelegate: class {
    /// Get the date for given section
    func collectionView(_ collectionView: UICollectionView, layout: JZWeekViewFlowLayout, dayForSection section: Int) -> Date
    /// Get the start time for given item indexPath
    func collectionView(_ collectionView: UICollectionView, layout: JZWeekViewFlowLayout, startTimeForItemAtIndexPath indexPath: IndexPath) -> Date
    /// Get the end time for given item indexPath
    func collectionView(_ collectionView: UICollectionView, layout: JZWeekViewFlowLayout, endTimeForItemAtIndexPath indexPath: IndexPath) -> Date
    /// TODO: Get the cell type for given item indexPath (Used for different cell types in the future)
    func collectionView(_ collectionView: UICollectionView, layout: JZWeekViewFlowLayout, cellTypeForItemAtIndexPath indexPath: IndexPath) -> String
}

open class JZWeekViewFlowLayout: UICollectionViewFlowLayout {

    // UI params
    var hourHeight: CGFloat!
    var rowHeaderWidth: CGFloat!
    var columnHeaderHeight: CGFloat!
    var allDayHeaderHeight: CGFloat = 0
    public var sectionWidth: CGFloat!
    public var hourGridDivision: JZHourGridDivision!
    var minuteHeight: CGFloat { return hourHeight / 60 }

    open var defaultHourHeight: CGFloat { return 50 }
    open var defaultRowHeaderWidth: CGFloat { return 42 }
    open var defaultColumnHeaderHeight: CGFloat { return 44 }
    open var defaultHourGridDivision: JZHourGridDivision { return .noneDiv }
    // You can change following constants
    open var defaultGridThickness: CGFloat { return 0.5 }
    open var defaultCurrentTimeLineHeight: CGFloat { return 10 }
    open var defaultAllDayOneLineHeight: CGFloat { return 30 }
    /// Margin for the flowLayout in collectionView
    open var contentsMargin: UIEdgeInsets { return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0) }
    open var itemMargin: UIEdgeInsets { return UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1) }
    /// weekview contentSize height
    open var maxSectionHeight: CGFloat {
        let height = hourHeight * 24 // statement too long for Swift 5 compiler
        return columnHeaderHeight + height + contentsMargin.top + contentsMargin.bottom + allDayHeaderHeight
    }

    let minOverlayZ = 1000  // Allows for 900 items in a section without z overlap issues
    let minCellZ = 100      // Allows for 100 items in a section's background
    let minBackgroundZ = 0

    // Attributes
    var cachedDayDateComponents = [Int: DateComponents]()
    var cachedCurrentTimeComponents = [Int: DateComponents]()
    var cachedStartTimeDateComponents = [IndexPath: DateComponents]()
    var cachedEndTimeDateComponents = [IndexPath: DateComponents]()
    var registeredDecorationClasses = [String: AnyClass]()
    var needsToPopulateAttributesForAllSections = true

    var currentTimeComponents: DateComponents {
        if cachedCurrentTimeComponents[0] == nil {
            cachedCurrentTimeComponents[0] = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        }
        return cachedCurrentTimeComponents[0]!
    }

    typealias AttDic = [IndexPath: UICollectionViewLayoutAttributes]

    var allAttributes = [UICollectionViewLayoutAttributes]()
    var itemAttributes = AttDic()
    var columnHeaderAttributes = AttDic()
    var columnHeaderBackgroundAttributes = AttDic()
    var rowHeaderAttributes = AttDic()
    var rowHeaderBackgroundAttributes = AttDic()
    var verticalGridlineAttributes = AttDic()
    var horizontalGridlineAttributes = AttDic()
    var cornerHeaderAttributes = AttDic()
    var currentTimeLineAttributes = AttDic()

    var allDayHeaderAttributes = AttDic()
    var allDayHeaderBackgroundAttributes = AttDic()
    var allDayCornerAttributes = AttDic()

    weak var delegate: WeekViewFlowLayoutDelegate?
    private var minuteTimer: Timer?

    // Default UI parameters Initializer
    override init() {
        super.init()

        setupUIParams()
        initializeMinuteTick()
    }

    // Custom UI parameters Initializer
    public init(hourHeight: CGFloat?=nil, rowHeaderWidth: CGFloat?=nil, columnHeaderHeight: CGFloat?=nil, hourGridDivision: JZHourGridDivision?=nil) {
        super.init()

        setupUIParams(hourHeight: hourHeight, rowHeaderWidth: rowHeaderWidth, columnHeaderHeight: columnHeaderHeight, hourGridDivision: hourGridDivision)
        initializeMinuteTick()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        minuteTimer?.invalidate()
    }

    private func setupUIParams(hourHeight: CGFloat?=nil, rowHeaderWidth: CGFloat?=nil, columnHeaderHeight: CGFloat?=nil, hourGridDivision: JZHourGridDivision?=nil) {
        self.hourHeight = hourHeight ?? defaultHourHeight
        self.rowHeaderWidth = rowHeaderWidth ?? defaultRowHeaderWidth
        self.columnHeaderHeight = columnHeaderHeight ?? defaultColumnHeaderHeight
        self.hourGridDivision = hourGridDivision ?? defaultHourGridDivision
    }

    private func initializeMinuteTick() {
        if #available(iOS 10.0, *) {
            minuteTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
                self?.minuteTick()
            }
        } else {
            minuteTimer = WeakTimer.scheduledTimer(timeInterval: 60, target: self, repeats: true) { [weak self] _ in
                self?.minuteTick()
            }
        }
    }

    @objc private func minuteTick() {
        cachedCurrentTimeComponents.removeAll()
        invalidateLayout()
    }

    // MARK: - UICollectionViewLayout
    override open func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        invalidateLayoutCache()
        prepare()
        super.prepare(forCollectionViewUpdates: updateItems)
    }

    override open func finalizeCollectionViewUpdates() {
        for subview in collectionView!.subviews {
            for decorationViewClass in registeredDecorationClasses.values {
                if subview.isKind(of: decorationViewClass) {
                    subview.removeFromSuperview()
                }
            }
        }
        collectionView!.reloadData()
    }

    public func registerDecorationViews(_ viewClasses: [UICollectionReusableView.Type]) {
        viewClasses.forEach {
            self.register($0, forDecorationViewOfKind: $0.className)
        }
    }

    override open func register(_ viewClass: AnyClass?, forDecorationViewOfKind elementKind: String) {
        super.register(viewClass, forDecorationViewOfKind: elementKind)
        registeredDecorationClasses[elementKind] = viewClass
    }

    override open func prepare() {
        super.prepare()

        if needsToPopulateAttributesForAllSections {
            prepareHorizontalTileSectionLayoutForSections(NSIndexSet(indexesIn:
                NSRange(location: 0, length: collectionView!.numberOfSections)))
            needsToPopulateAttributesForAllSections = false
        }

        let needsToPopulateAllAttributes = (allAttributes.count == 0)

        if needsToPopulateAllAttributes {
            allAttributes.append(contentsOf: columnHeaderAttributes.values)
            allAttributes.append(contentsOf: columnHeaderBackgroundAttributes.values)
            allAttributes.append(contentsOf: rowHeaderAttributes.values)
            allAttributes.append(contentsOf: rowHeaderBackgroundAttributes.values)
            allAttributes.append(contentsOf: verticalGridlineAttributes.values)
            allAttributes.append(contentsOf: horizontalGridlineAttributes.values)
            allAttributes.append(contentsOf: cornerHeaderAttributes.values)
            allAttributes.append(contentsOf: currentTimeLineAttributes.values)
            allAttributes.append(contentsOf: itemAttributes.values)

            allAttributes.append(contentsOf: allDayCornerAttributes.values)
            allAttributes.append(contentsOf: allDayHeaderAttributes.values)
            allAttributes.append(contentsOf: allDayHeaderBackgroundAttributes.values)
        }
    }

    open func prepareHorizontalTileSectionLayoutForSections(_ sectionIndexes: NSIndexSet) {
        guard let collectionView = collectionView, collectionView.numberOfSections != 0 else { return }

        var attributes =  UICollectionViewLayoutAttributes()

        let sectionHeight = (hourHeight * 24).toDecimal1Value()
        let calendarGridMinY = columnHeaderHeight + contentsMargin.top + allDayHeaderHeight
        let calendarContentMinX = rowHeaderWidth + contentsMargin.left
        let calendarContentMinY = columnHeaderHeight + contentsMargin.top + allDayHeaderHeight

        // Current time line
        // TODO: Should improve this method, otherwise every column will display a timeline view
        sectionIndexes.enumerate(_:) { (section, _) in
            let sectionMinX = calendarContentMinX + sectionWidth * CGFloat(section)
            let timeY = calendarContentMinY + (CGFloat(currentTimeComponents.hour!).toDecimal1Value() * hourHeight
                + CGFloat(currentTimeComponents.minute!) * minuteHeight)
            let currentTimeHorizontalGridlineMinY = timeY - (defaultGridThickness / 2.0).toDecimal1Value() - defaultCurrentTimeLineHeight/2
            (attributes, currentTimeLineAttributes) = layoutAttributesForSupplemantaryView(at: IndexPath(item: 0, section: section),
                                                                                           ofKind: JZSupplementaryViewKinds.currentTimeline,
                                                                                           withItemCache: currentTimeLineAttributes)
            attributes.frame = CGRect(x: sectionMinX, y: currentTimeHorizontalGridlineMinY, width: sectionWidth, height: defaultCurrentTimeLineHeight)
            attributes.zIndex = zIndexForElementKind(JZSupplementaryViewKinds.currentTimeline)
        }

        // Corner Header
        (attributes, cornerHeaderAttributes) = layoutAttributesForSupplemantaryView(at: IndexPath(item: 0, section: 0),
                                                                                    ofKind: JZSupplementaryViewKinds.cornerHeader,
                                                                                    withItemCache: cornerHeaderAttributes)
        attributes.frame = CGRect(origin: collectionView.contentOffset, size: CGSize(width: rowHeaderWidth, height: columnHeaderHeight))
        attributes.zIndex = zIndexForElementKind(JZSupplementaryViewKinds.cornerHeader)

        // Row header
        let rowHeaderMinX = fmax(collectionView.contentOffset.x, 0)

        for rowHeaderIndex in 0...24 {
            (attributes, rowHeaderAttributes) = layoutAttributesForSupplemantaryView(at: IndexPath(item: rowHeaderIndex, section: 0),
                                                                                     ofKind: JZSupplementaryViewKinds.rowHeader,
                                                                                     withItemCache: rowHeaderAttributes)
            let rowHeaderMinY = calendarContentMinY + hourHeight * CGFloat(rowHeaderIndex) - (hourHeight / 2.0).toDecimal1Value()
            attributes.frame = CGRect(x: rowHeaderMinX, y: rowHeaderMinY, width: rowHeaderWidth, height: hourHeight)
            attributes.zIndex = zIndexForElementKind(JZSupplementaryViewKinds.rowHeader)
        }

        // Row Header Background
        (attributes, rowHeaderBackgroundAttributes) = layoutAttributesForDecorationView(at: IndexPath(item: 0, section: 0),
                                                                                        ofKind: JZDecorationViewKinds.rowHeaderBackground,
                                                                                        withItemCache: rowHeaderBackgroundAttributes)
        attributes.frame = CGRect(x: rowHeaderMinX, y: collectionView.contentOffset.y, width: rowHeaderWidth, height: collectionView.frame.height)
        attributes.zIndex = zIndexForElementKind(JZDecorationViewKinds.rowHeaderBackground)

        // All-Day header
        let allDayHeaderMinY = fmax(collectionView.contentOffset.y + columnHeaderHeight, columnHeaderHeight)

        sectionIndexes.enumerate(_:) { (section, _) in
            let sectionMinX = calendarContentMinX + sectionWidth * CGFloat(section)

            (attributes, allDayHeaderAttributes) =
                layoutAttributesForSupplemantaryView(at: IndexPath(item: 0, section: section),
                                                     ofKind: JZSupplementaryViewKinds.allDayHeader,
                                                     withItemCache: allDayHeaderAttributes)
            attributes.frame = CGRect(x: sectionMinX, y: allDayHeaderMinY,
                                      width: sectionWidth, height: allDayHeaderHeight)
            attributes.zIndex = zIndexForElementKind(JZSupplementaryViewKinds.allDayHeader)
        }

        // All-Day header background
        (attributes, allDayHeaderBackgroundAttributes) =
            layoutAttributesForDecorationView(at: IndexPath(item: 0, section: 0),
                                              ofKind: JZDecorationViewKinds.allDayHeaderBackground,
                                              withItemCache: allDayHeaderBackgroundAttributes)
        attributes.frame = CGRect(origin: CGPoint(x: collectionView.contentOffset.x, y: collectionView.contentOffset.y + columnHeaderHeight) ,
                                  size: CGSize(width: collectionView.frame.width,
                                               height: allDayHeaderHeight))
        attributes.zIndex = zIndexForElementKind(JZDecorationViewKinds.allDayHeaderBackground)

        (attributes, allDayCornerAttributes) =
            layoutAttributesForDecorationView(at: IndexPath(item: 0, section: 0),
                                              ofKind: JZDecorationViewKinds.allDayCorner,
                                              withItemCache: allDayCornerAttributes)
        attributes.frame = CGRect(origin: CGPoint(x: collectionView.contentOffset.x, y: collectionView.contentOffset.y + columnHeaderHeight),
                                  size: CGSize(width: rowHeaderWidth, height: allDayHeaderHeight))
        attributes.zIndex = zIndexForElementKind(JZDecorationViewKinds.allDayCorner)

        // column header background
        (attributes, columnHeaderBackgroundAttributes) = layoutAttributesForDecorationView(at: IndexPath(item: 0, section: 0),
                                                                                           ofKind: JZDecorationViewKinds.columnHeaderBackground,
                                                                                           withItemCache: columnHeaderBackgroundAttributes)
        let attributesHeight = columnHeaderHeight + (collectionView.contentOffset.y < 0 ? abs(collectionView.contentOffset.y) : 0 )
        attributes.frame = CGRect(origin: collectionView.contentOffset, size: CGSize(width: collectionView.frame.width, height: attributesHeight))
        attributes.zIndex = zIndexForElementKind(JZDecorationViewKinds.columnHeaderBackground)

        // Column Header
        let columnHeaderMinY = fmax(collectionView.contentOffset.y, 0.0)

        sectionIndexes.enumerate(_:) { (section, _) in
            let sectionMinX = calendarContentMinX + sectionWidth * CGFloat(section)
            (attributes, columnHeaderAttributes) = layoutAttributesForSupplemantaryView(at: IndexPath(item: 0, section: section),
                                                                                        ofKind: JZSupplementaryViewKinds.columnHeader,
                                                                                        withItemCache: columnHeaderAttributes)
            attributes.frame = CGRect(x: sectionMinX, y: columnHeaderMinY, width: sectionWidth, height: columnHeaderHeight)
            attributes.zIndex = zIndexForElementKind(JZSupplementaryViewKinds.columnHeader)

            layoutVerticalGridLinesAttributes(section: section, sectionX: sectionMinX, calendarGridMinY: calendarGridMinY, sectionHeight: sectionHeight)
            layoutItemsAttributes(section: section, sectionX: sectionMinX, calendarStartY: calendarGridMinY)
        }

        layoutHorizontalGridLinesAttributes(calendarStartX: calendarContentMinX, calendarStartY: calendarContentMinY)
    }

    // MARK: - Layout Attributes
    func layoutItemsAttributes(section: Int, sectionX: CGFloat, calendarStartY: CGFloat) {
        var attributes =  UICollectionViewLayoutAttributes()
        var sectionItemAttributes = [UICollectionViewLayoutAttributes]()

        for item in 0..<collectionView!.numberOfItems(inSection: section) {
            let itemIndexPath = IndexPath(item: item, section: section)
            (attributes, itemAttributes) = layoutAttributesForCell(at: itemIndexPath, withItemCache: itemAttributes)

            let itemStartTime = startTimeForIndexPath(itemIndexPath)
            let itemEndTime = endTimeForIndexPath(itemIndexPath)
            let startHourY = CGFloat(itemStartTime.hour!) * hourHeight
            let startMinuteY = CGFloat(itemStartTime.minute!) * minuteHeight
            let endHourY: CGFloat
            let endMinuteY = CGFloat(itemEndTime.minute!) * minuteHeight

            if itemEndTime.day! != itemStartTime.day! {
                endHourY = CGFloat(Calendar.current.maximumRange(of: .hour)!.count) * hourHeight + CGFloat(itemEndTime.hour!) * hourHeight
            } else {
                endHourY = CGFloat(itemEndTime.hour!) * hourHeight
            }

            let itemMinX = (sectionX + itemMargin.left).toDecimal1Value()
            let itemMinY = (startHourY + startMinuteY + calendarStartY + itemMargin.top).toDecimal1Value()
            let itemMaxX = (itemMinX + (sectionWidth - (itemMargin.left + itemMargin.right))).toDecimal1Value()
            let itemMaxY = (endHourY + endMinuteY + calendarStartY - itemMargin.bottom).toDecimal1Value()

            attributes.frame = CGRect(x: itemMinX, y: itemMinY, width: itemMaxX - itemMinX, height: itemMaxY - itemMinY)
            attributes.zIndex = zIndexForElementKind(JZSupplementaryViewKinds.eventCell)
            sectionItemAttributes.append(attributes)
        }

        adjustItemsForOverlap(sectionItemAttributes, inSection: section, sectionMinX: sectionX,
                              currentSectionZ: zIndexForElementKind(JZSupplementaryViewKinds.eventCell))
    }

    func layoutVerticalGridLinesAttributes(section: Int, sectionX: CGFloat, calendarGridMinY: CGFloat, sectionHeight: CGFloat) {
        var attributes = UICollectionViewLayoutAttributes()

        (attributes, verticalGridlineAttributes) = layoutAttributesForDecorationView(at: IndexPath(item: 0, section: section),
                                                                                     ofKind: JZDecorationViewKinds.verticalGridline,
                                                                                     withItemCache: verticalGridlineAttributes)
        attributes.frame = CGRect(x: (sectionX - defaultGridThickness / 2.0).toDecimal1Value(), y: calendarGridMinY,
                                  width: defaultGridThickness, height: sectionHeight)
        attributes.zIndex = zIndexForElementKind(JZDecorationViewKinds.verticalGridline)
    }

    func layoutHorizontalGridLinesAttributes(calendarStartX: CGFloat, calendarStartY: CGFloat) {
        var horizontalGridlineIndex = 0
        let calendarGridWidth = collectionViewContentSize.width - rowHeaderWidth - contentsMargin.left - contentsMargin.right
        var attributes = UICollectionViewLayoutAttributes()

        for hour in 0...24 {
            (attributes, horizontalGridlineAttributes) = layoutAttributesForDecorationView(at: IndexPath(item: horizontalGridlineIndex, section: 0),
                                                                                           ofKind: JZDecorationViewKinds.horizontalGridline,
                                                                                           withItemCache: horizontalGridlineAttributes)
            let horizontalGridlineXOffset = calendarStartX
            let horizontalGridlineMinX = fmax(horizontalGridlineXOffset, collectionView!.contentOffset.x + horizontalGridlineXOffset)
            let horizontalGridlineMinY = (calendarStartY + (hourHeight * CGFloat(hour))) - (defaultGridThickness / 2.0).toDecimal1Value()
            let horizontalGridlineWidth = fmin(calendarGridWidth, collectionView!.frame.width)

            attributes.frame = CGRect(x: horizontalGridlineMinX, y: horizontalGridlineMinY,
                                      width: horizontalGridlineWidth, height: defaultGridThickness)
            attributes.zIndex = zIndexForElementKind(JZDecorationViewKinds.horizontalGridline)
            horizontalGridlineIndex += 1

            if hourGridDivision.rawValue > 0 {
                horizontalGridlineIndex = drawHourDividersAtGridLineIndex(horizontalGridlineIndex, hour: hour,
                                                                          startX: horizontalGridlineMinX,
                                                                          startY: horizontalGridlineMinY,
                                                                          gridlineWidth: horizontalGridlineWidth)
            }
        }
    }

    func drawHourDividersAtGridLineIndex(_ gridlineIndex: Int, hour: Int, startX calendarStartX: CGFloat,
                                         startY calendarStartY: CGFloat, gridlineWidth: CGFloat) -> Int {
        var _gridlineIndex = gridlineIndex
        var attributes = UICollectionViewLayoutAttributes()
        let numberOfDivisions = 60 / hourGridDivision.rawValue
        let divisionHeight = hourHeight / CGFloat(numberOfDivisions)

        for division in 1..<numberOfDivisions {
            let horizontalGridlineIndexPath = IndexPath(item: _gridlineIndex, section: 0)

            (attributes, horizontalGridlineAttributes) = layoutAttributesForDecorationView(at: horizontalGridlineIndexPath,
                                                                                           ofKind: JZDecorationViewKinds.horizontalGridline,
                                                                                           withItemCache: horizontalGridlineAttributes)
            let horizontalGridlineMinY = (calendarStartY + (divisionHeight * CGFloat(division)) - (defaultGridThickness / 2.0)).toDecimal1Value()
            attributes.frame = CGRect(x: calendarStartX, y: horizontalGridlineMinY, width: gridlineWidth, height: defaultGridThickness)
            attributes.alpha = 0.3
            attributes.zIndex = zIndexForElementKind(JZDecorationViewKinds.horizontalGridline)

            _gridlineIndex += 1

        }
        return _gridlineIndex
    }

    override open var collectionViewContentSize: CGSize {
        return CGSize(width: rowHeaderWidth + sectionWidth * CGFloat(collectionView!.numberOfSections),
                      height: maxSectionHeight)
    }

    // MARK: - Layout
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return itemAttributes[indexPath]
    }

    override open func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        switch elementKind {
        case JZSupplementaryViewKinds.columnHeader:
            return columnHeaderAttributes[indexPath]
        case JZSupplementaryViewKinds.rowHeader:
            return rowHeaderAttributes[indexPath]
        case JZSupplementaryViewKinds.cornerHeader:
            return cornerHeaderAttributes[indexPath]
        case JZSupplementaryViewKinds.allDayHeader:
            return allDayHeaderAttributes[indexPath]
        case JZSupplementaryViewKinds.currentTimeline:
            return currentTimeLineAttributes[indexPath]
        default:
            return nil
        }
    }

    override open func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        switch elementKind {
        case JZDecorationViewKinds.verticalGridline:
            return verticalGridlineAttributes[indexPath]
        case JZDecorationViewKinds.horizontalGridline:
            return horizontalGridlineAttributes[indexPath]
        case JZDecorationViewKinds.rowHeaderBackground:
            return rowHeaderBackgroundAttributes[indexPath]
        case JZDecorationViewKinds.columnHeaderBackground:
            return columnHeaderBackgroundAttributes[indexPath]
        case JZDecorationViewKinds.allDayHeaderBackground:
            return allDayHeaderBackgroundAttributes[indexPath]
        case JZDecorationViewKinds.allDayCorner:
            return allDayCornerAttributes[indexPath]
        default:
            return nil
        }
    }

    // MARK: - Layout
    func layoutAttributesForCell(at indexPath: IndexPath, withItemCache itemCache: AttDic) -> (UICollectionViewLayoutAttributes, AttDic) {
        var layoutAttributes = itemCache[indexPath]

        if layoutAttributes == nil {
            var _itemCache = itemCache
            layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            _itemCache[indexPath] = layoutAttributes
            return (layoutAttributes!, _itemCache)
        } else {
            return (layoutAttributes!, itemCache)
        }
    }

    func layoutAttributesForDecorationView(at indexPath: IndexPath,
                                           ofKind kind: String,
                                           withItemCache itemCache: AttDic) -> (UICollectionViewLayoutAttributes, AttDic) {
        var layoutAttributes = itemCache[indexPath]

        if layoutAttributes == nil {
            var _itemCache = itemCache
            layoutAttributes = UICollectionViewLayoutAttributes(forDecorationViewOfKind: kind, with: indexPath)
            _itemCache[indexPath] = layoutAttributes
            return (layoutAttributes!, _itemCache)
        } else {
            return (layoutAttributes!, itemCache)
        }
    }

    func layoutAttributesForDecorationView(customAttributes: UICollectionViewLayoutAttributes,
                                           withItemCache itemCache: AttDic) -> (UICollectionViewLayoutAttributes, AttDic) {
        var _itemCache = itemCache
        _itemCache[customAttributes.indexPath] = customAttributes
        return (customAttributes, _itemCache)
    }

    private func layoutAttributesForSupplemantaryView(at indexPath: IndexPath,
                                                      ofKind kind: String,
                                                      withItemCache itemCache: AttDic) -> (UICollectionViewLayoutAttributes, AttDic) {
        var layoutAttributes = itemCache[indexPath]

        if layoutAttributes == nil {
            var _itemCache = itemCache
            layoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: kind, with: indexPath)
            _itemCache[indexPath] = layoutAttributes
            return (layoutAttributes!, _itemCache)
        } else {
            return (layoutAttributes!, itemCache)
        }
    }

    /**
     New method to adjust items layout for overlap
     
     Known existing issues:
     1. If some events have the same overlap count as others and at the same time, those events are not adjusted yet, then this method will calculate and divide them evenly in the section.
        However, there might be some cases, in very complicated situation, those same overlap count groups might exist already adjusted item overlapping with one of current group items, which
        means the order is wrong.
     2. Efficiency issue for getAvailableRanges and the rest of the code in this method
    */
    open func adjustItemsForOverlap(_ sectionItemAttributes: [UICollectionViewLayoutAttributes], inSection: Int, sectionMinX: CGFloat, currentSectionZ: Int) {
        let (maxOverlapIntervalCount, overlapGroups) = groupOverlapItems(items: sectionItemAttributes)
        guard maxOverlapIntervalCount > 1 else { return }

        var sortedOverlapGroups = overlapGroups.sorted { $0.count > $1.count }
        var adjustedItems = Set<UICollectionViewLayoutAttributes>()
        var sectionZ = currentSectionZ

        // First draw the largest overlap items layout (only this case itemWidth is fixed and always at the right position)
        let largestOverlapCountGroup = sortedOverlapGroups[0]
        setItemsAdjustedAttributes(fullWidth: sectionWidth, items: largestOverlapCountGroup, currentMinX: sectionMinX, sectionZ: &sectionZ, adjustedItems: &adjustedItems)

        for index in 1..<sortedOverlapGroups.count {
            let group = sortedOverlapGroups[index]
            var unadjustedItems = [UICollectionViewLayoutAttributes]()
            // unavailable area and already sorted
            var adjustedRanges = [ClosedRange<CGFloat>]()
            group.forEach {
                if adjustedItems.contains($0) {
                    adjustedRanges.append($0.frame.minX...$0.frame.maxX)
                } else {
                    unadjustedItems.append($0)
                }
            }
            guard adjustedRanges.count > 0 else {
                // No need to recalulate the layout
                setItemsAdjustedAttributes(fullWidth: sectionWidth, items: group, currentMinX: sectionMinX, sectionZ: &sectionZ, adjustedItems: &adjustedItems)
                continue
            }
            guard unadjustedItems.count > 0 else { continue }

            let availableRanges = getAvailableRanges(sectionRange: sectionMinX...sectionMinX + sectionWidth, adjustedRanges: adjustedRanges)
            let minItemDivisionWidth = (sectionWidth / CGFloat(largestOverlapCountGroup.count)).toDecimal1Value()
            var i = 0, j = 0
            while i < unadjustedItems.count && j < availableRanges.count {
                let availableRange = availableRanges[j]
                let availableWidth = availableRange.upperBound - availableRange.lowerBound
                let availableMaxItemsCount = Int(round(availableWidth / minItemDivisionWidth))
                let leftUnadjustedItemsCount = unadjustedItems.count - i
                if leftUnadjustedItemsCount <= availableMaxItemsCount {
                    // All left unadjusted items can evenly divide the current available area
                    setItemsAdjustedAttributes(fullWidth: availableWidth, items: Array(unadjustedItems[i..<unadjustedItems.count]), currentMinX: availableRange.lowerBound, sectionZ: &sectionZ, adjustedItems: &adjustedItems)
                    break
                } else {
                    // This current available interval cannot afford all left unadjusted items
                    setItemsAdjustedAttributes(fullWidth: availableWidth, items: Array(unadjustedItems[i..<i+availableMaxItemsCount]), currentMinX: availableRange.lowerBound, sectionZ: &sectionZ, adjustedItems: &adjustedItems)
                    i += availableMaxItemsCount
                    j += 1
                }
            }
        }
    }

    /// Get current available ranges for unadjusted items with given current section range and already adjusted ranges
    ///
    /// - Parameters:
    ///   - sectionRange: current section minX and maxX range
    ///   - adjustedRanges: already adjusted ranges(cannot draw items on these ranges)
    /// - Returns: All available ranges after substract all adjusted ranges
    func getAvailableRanges(sectionRange: ClosedRange<CGFloat>, adjustedRanges: [ClosedRange<CGFloat>]) -> [ClosedRange<CGFloat>] {
        var availableRanges: [ClosedRange<CGFloat>] = [sectionRange]
        let sortedAdjustedRange = adjustedRanges.sorted { $0.lowerBound < $1.lowerBound }
        for adjustedRange in sortedAdjustedRange {
            let lastAvailableRange = availableRanges.last!
            if adjustedRange.lowerBound > lastAvailableRange.lowerBound + itemMargin.left + itemMargin.right {
                var currentAvailableRanges = [ClosedRange<CGFloat>]()
                // TODO: still exists 707.1999 and 708, needs to be fixed
                if adjustedRange.upperBound + itemMargin.right >= lastAvailableRange.upperBound {
                    // Adjusted range covers right part of the last available range
                    let leftAvailableRange = lastAvailableRange.lowerBound...adjustedRange.lowerBound
                    currentAvailableRanges.append(leftAvailableRange)
                } else {
                    // Adjusted range is in middle of the last available range
                    let leftAvailableRange = lastAvailableRange.lowerBound...adjustedRange.lowerBound
                    let rightAvailableRange = adjustedRange.upperBound...lastAvailableRange.upperBound
                    currentAvailableRanges = [leftAvailableRange, rightAvailableRange]
                }
                availableRanges.removeLast()
                availableRanges += currentAvailableRanges
            } else {
                if adjustedRange.upperBound > lastAvailableRange.lowerBound {
                    let availableRange = adjustedRange.upperBound...lastAvailableRange.upperBound
                    availableRanges.removeLast()
                    availableRanges.append(availableRange)
                } else {
                    // if false, means this adjustedRange is included in last adjustedRange, like (3, 7) & (5, 7) no need to do anything
                }
            }
        }
        return availableRanges
    }

    /// Set provided items correct adjusted layout attributes
    ///
    /// - Parameters:
    ///   - fullWidth: Full width for items can be divided
    ///   - items: All the items need to be adjusted
    ///   - currentMinX: Current minimum contentOffset(start position of the first item)
    ///   - sectionZ: section Z value (inout)
    ///   - adjustedItems: already adjused item (inout)
    private func setItemsAdjustedAttributes(fullWidth: CGFloat,
                                            items: [UICollectionViewLayoutAttributes],
                                            currentMinX: CGFloat,
                                            sectionZ: inout Int,
                                            adjustedItems: inout Set<UICollectionViewLayoutAttributes>) {
        let divisionWidth = (fullWidth / CGFloat(items.count)).toDecimal1Value()
        let itemWidth = divisionWidth - itemMargin.left - itemMargin.right
        for (index, itemAttribute) in items.enumerated() {
            itemAttribute.frame.origin.x = (currentMinX + itemMargin.left + CGFloat(index) * divisionWidth).toDecimal1Value()
            itemAttribute.frame.size = CGSize(width: itemWidth, height: itemAttribute.frame.height)
            itemAttribute.zIndex = sectionZ
            sectionZ += 1
            adjustedItems.insert(itemAttribute)
        }
    }

    /// Get maximum number of currently overlapping items, used to refer only
    ///
    /// Algorithm from http://www.zrzahid.com/maximum-number-of-overlapping-intervals/
    private func maxOverlapIntervalCount(startY: [CGFloat], endY: [CGFloat]) -> Int {
        var maxOverlap = 0, currentOverlap = 0
        let sortedStartY = startY.sorted(), sortedEndY = endY.sorted()

        var i = 0, j = 0
        while i < sortedStartY.count && j < sortedEndY.count {
            if sortedStartY[i] < sortedEndY[j] {
                currentOverlap += 1
                maxOverlap = max(maxOverlap, currentOverlap)
                i += 1
            } else {
                currentOverlap -= 1
                j += 1
            }
        }
        return maxOverlap
    }

    /// Group all the overlap items depending on the maximum overlap items
    ///
    /// Refer to the previous algorithm but integrated with groups
    /// - Parameter items: All the items(cells) in the UICollectionView
    /// - Returns: maxOverlapIntervalCount and all the maximum overlap groups
    func groupOverlapItems(items: [UICollectionViewLayoutAttributes]) -> (maxOverlapIntervalCount: Int, overlapGroups: [[UICollectionViewLayoutAttributes]]) {
        var maxOverlap = 0, currentOverlap = 0
        let sortedMinYItems = items.sorted { $0.frame.minY < $1.frame.minY }
        let sortedMaxYItems = items.sorted { $0.frame.maxY < $1.frame.maxY }
        let itemCount = items.count

        var i = 0, j = 0
        var overlapGroups = [[UICollectionViewLayoutAttributes]]()
        var currentOverlapGroup = [UICollectionViewLayoutAttributes]()
        var shouldAppendToOverlapGroups: Bool = false
        while i < itemCount && j < itemCount {
            if sortedMinYItems[i].frame.minY < sortedMaxYItems[j].frame.maxY {
                currentOverlap += 1
                maxOverlap = max(maxOverlap, currentOverlap)
                shouldAppendToOverlapGroups = true
                currentOverlapGroup.append(sortedMinYItems[i])
                i += 1
            } else {
                currentOverlap -= 1
                // should not append to group with continuous minus
                if shouldAppendToOverlapGroups {
                    if currentOverlapGroup.count > 1 { overlapGroups.append(currentOverlapGroup) }
                    shouldAppendToOverlapGroups = false
                }
                currentOverlapGroup.removeAll { $0 == sortedMaxYItems[j] }
                j += 1
            }
        }
        // Add last currentOverlapGroup
        if currentOverlapGroup.count > 1 { overlapGroups.append(currentOverlapGroup) }
        return (maxOverlap, overlapGroups)
    }

    func invalidateLayoutCache() {
        needsToPopulateAttributesForAllSections = true

        cachedDayDateComponents.removeAll()
        cachedStartTimeDateComponents.removeAll()
        cachedEndTimeDateComponents.removeAll()

        currentTimeLineAttributes.removeAll()
        verticalGridlineAttributes.removeAll()
        horizontalGridlineAttributes.removeAll()
        columnHeaderAttributes.removeAll()
        columnHeaderBackgroundAttributes.removeAll()
        rowHeaderAttributes.removeAll()
        rowHeaderBackgroundAttributes.removeAll()
        cornerHeaderAttributes.removeAll()
        itemAttributes.removeAll()
        allAttributes.removeAll()

        allDayHeaderAttributes.removeAll()
        allDayHeaderBackgroundAttributes.removeAll()
        allDayCornerAttributes.removeAll()
    }

    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let visibleSections = NSMutableIndexSet()
        NSIndexSet(indexesIn: NSRange(location: 0, length: collectionView!.numberOfSections))
            .enumerate(_:) { (section: Int, _: UnsafeMutablePointer<ObjCBool>) -> Void in
                let sectionRect = rectForSection(section)
                if rect.intersects(sectionRect) {
                    visibleSections.add(section)
                }
        }
        prepareHorizontalTileSectionLayoutForSections(visibleSections)

        return allAttributes.filter({ rect.intersects($0.frame) })
    }

    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    // MARK: - Section sizing
    open func rectForSection(_ section: Int) -> CGRect {
        return CGRect(x: rowHeaderWidth + sectionWidth * CGFloat(section), y: 0,
                      width: sectionWidth, height: collectionViewContentSize.height)
    }

    // MARK: - Delegate Wrapper

    /// Internal use only, use getDateForSection in JZBaseWeekView instead
    private func daysForSection(_ section: Int) -> DateComponents {
        if cachedDayDateComponents[section] != nil {
            return cachedDayDateComponents[section]!
        }

        let day = delegate?.collectionView(collectionView!, layout: self, dayForSection: section)
        guard day != nil else { fatalError() }
        let startOfDay = Calendar.current.startOfDay(for: day!)
        let dayDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: startOfDay)
        cachedDayDateComponents[section] = dayDateComponents
        return dayDateComponents
    }

    private func startTimeForIndexPath(_ indexPath: IndexPath) -> DateComponents {
        if cachedStartTimeDateComponents[indexPath] != nil {
            return cachedStartTimeDateComponents[indexPath]!
        } else {
            if let date = delegate?.collectionView(collectionView!, layout: self, startTimeForItemAtIndexPath: indexPath) {
                cachedStartTimeDateComponents[indexPath] = Calendar.current.dateComponents([.day, .hour, .minute], from: date)
                return cachedStartTimeDateComponents[indexPath]!
            } else {
                fatalError()
            }
        }
    }

    private func endTimeForIndexPath(_ indexPath: IndexPath) -> DateComponents {
        if cachedEndTimeDateComponents[indexPath] != nil {
            return cachedEndTimeDateComponents[indexPath]!
        } else {
            if let date = delegate?.collectionView(collectionView!, layout: self, endTimeForItemAtIndexPath: indexPath) {
                cachedEndTimeDateComponents[indexPath] = Calendar.current.dateComponents([.day, .hour, .minute], from: date)
                return cachedEndTimeDateComponents[indexPath]!
            } else {
                fatalError()
            }
        }
    }

    open func timeForRowHeader(at indexPath: IndexPath) -> Date {
        var components = daysForSection(indexPath.section)
        components.hour = indexPath.item
        return Calendar.current.date(from: components)!
    }

    open func dateForColumnHeader(at indexPath: IndexPath) -> Date {
        let day = delegate?.collectionView(collectionView!, layout: self, dayForSection: indexPath.section)
        return Calendar.current.startOfDay(for: day!)
    }

    // MARK: - z index
    open func zIndexForElementKind(_ kind: String) -> Int {
        switch kind {
        case JZSupplementaryViewKinds.cornerHeader, JZDecorationViewKinds.allDayCorner:
            return minOverlayZ + 10
        case JZSupplementaryViewKinds.allDayHeader:
            return minOverlayZ + 9
        case JZDecorationViewKinds.allDayHeaderBackground:
            return minOverlayZ + 8
        case JZSupplementaryViewKinds.rowHeader:
            return minOverlayZ + 7
        case JZDecorationViewKinds.rowHeaderBackground:
            return minOverlayZ + 6
        case JZSupplementaryViewKinds.columnHeader:
            return minOverlayZ + 5
        case JZDecorationViewKinds.columnHeaderBackground:
            return minOverlayZ + 4
        case JZSupplementaryViewKinds.currentTimeline:
            return minOverlayZ + 3
        case JZDecorationViewKinds.horizontalGridline:
            return minBackgroundZ + 2
        case JZDecorationViewKinds.verticalGridline:
            return minBackgroundZ + 1
        default:
            return minCellZ
        }
    }
}
