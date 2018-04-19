//
//  WeekViewFlowLayout.swift
//  JZCalendarView
//
//  Created by Jeff Zhang on 28/3/18.
//  Inspired and followed by WRCalendarView (https://github.com/wayfinders/WRCalendarView)
//

import UIKit

public protocol WeekViewFlowLayoutDelegate: class {
    /// Get the date for given section
    func collectionView(_ collectionView: UICollectionView, layout: WeekViewFlowLayout, dayForSection section: Int) -> Date
    /// Get the start time for given item indexPath
    func collectionView(_ collectionView: UICollectionView, layout: WeekViewFlowLayout, startTimeForItemAtIndexPath indexPath: IndexPath) -> Date
    /// Get the end time for given item indexPath
    func collectionView(_ collectionView: UICollectionView, layout: WeekViewFlowLayout, endTimeForItemAtIndexPath indexPath: IndexPath) -> Date
    /// TODO: Get the cell type for given item indexPath (Used for different cell types in the future)
    func collectionView(_ collectionView: UICollectionView, layout: WeekViewFlowLayout, cellTypeForItemAtIndexPath indexPath: IndexPath) -> String
}

open class WeekViewFlowLayout: UICollectionViewFlowLayout {
    
    // UI params
    var hourHeight: CGFloat!
    var rowHeaderWidth: CGFloat!
    var columnHeaderHeight: CGFloat!
    var sectionWidth: CGFloat!
    var hourGridDivision: HourGridDivision!
    var minuteHeight: CGFloat { return hourHeight / 60 }
    
    open var defaultHourHeight: CGFloat = 50
    open var defaultRowHeaderWidth: CGFloat = 42
    open var defaultColumnHeaderHeight: CGFloat = 44
    open var defaultHourGridDivision = HourGridDivision.noneDiv
    //If you want to change following constants, subclass the WeekViewFlowLayout, and override them
    open var defaultGridThickness: CGFloat = 0.5
    open var defaultCurrentTimeLineHeight: CGFloat = 10
    open var contentsMargin = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0) //Margin for the flowLayout in collectionView
    open var sectionMargin = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    open var itemMargin = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    
    private var maxSectionHeight: CGFloat { return columnHeaderHeight + hourHeight * 24 + contentsMargin.top + contentsMargin.bottom } //weekview contentSize height
    
    let minOverlayZ = 1000  // Allows for 900 items in a section without z overlap issues
    let minCellZ = 100      // Allows for 100 items in a section's background
    let minBackgroundZ = 0
    
    // Attributes
    var cachedDayDateComponents = Dictionary<Int, DateComponents>()
    var cachedCurrentTimeComponents = Dictionary<Int, DateComponents>()
    var cachedStartTimeDateComponents = Dictionary<IndexPath, DateComponents>()
    var cachedEndTimeDateComponents = Dictionary<IndexPath, DateComponents>()
    var registeredDecorationClasses = Dictionary<String, AnyClass>()
    var needsToPopulateAttributesForAllSections = true
    
    var currentTimeComponents: DateComponents {
        if cachedCurrentTimeComponents[0] == nil {
            cachedCurrentTimeComponents[0] = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        }
        return cachedCurrentTimeComponents[0]!
    }
    
    typealias AttDic = Dictionary<IndexPath, UICollectionViewLayoutAttributes>
    
    var allAttributes = Array<UICollectionViewLayoutAttributes>()
    var itemAttributes = AttDic()
    var columnHeaderAttributes = AttDic()
    var columnHeaderBackgroundAttributes = AttDic()
    var rowHeaderAttributes = AttDic()
    var rowHeaderBackgroundAttributes = AttDic()
    var verticalGridlineAttributes = AttDic()
    var horizontalGridlineAttributes = AttDic()
    var cornerHeaderAttributes = AttDic()
    var currentTimeLineAttributes = AttDic()
    
    weak var delegate: WeekViewFlowLayoutDelegate?
    private var minuteTimer: Timer?
    
    // Default UI parameters Initializer
    override init() {
        super.init()
        
        setupUIParams()
        initializeMinuteTick()
    }
    
    // Custom UI parameters Initializer
    init(hourHeight:CGFloat?=nil, rowHeaderWidth:CGFloat?=nil, columnHeaderHeight:CGFloat?=nil, hourGridDivision:HourGridDivision?=nil) {
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
    
    private func setupUIParams(hourHeight:CGFloat?=nil, rowHeaderWidth:CGFloat?=nil, columnHeaderHeight:CGFloat?=nil, hourGridDivision:HourGridDivision?=nil) {
        self.hourHeight = hourHeight ?? defaultHourHeight
        self.rowHeaderWidth = rowHeaderWidth ?? defaultRowHeaderWidth
        self.columnHeaderHeight = columnHeaderHeight ?? defaultColumnHeaderHeight
        self.hourGridDivision = hourGridDivision ?? defaultHourGridDivision
    }
    
    private func initializeMinuteTick() {
        let fireDate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
        minuteTimer = Timer(fireAt: fireDate, interval: 60, target: self, selector: #selector(minuteTick), userInfo: nil, repeats: true)
        RunLoop.current.add(minuteTimer!, forMode: .defaultRunLoopMode)
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
        }
    }
    
    open func prepareHorizontalTileSectionLayoutForSections(_ sectionIndexes: NSIndexSet) {
        guard collectionView!.numberOfSections != 0 else { return }
        
        var attributes =  UICollectionViewLayoutAttributes()
        
        let sectionWidth = sectionMargin.left + self.sectionWidth + sectionMargin.right
        let sectionHeight = nearbyint(hourHeight * 24 + sectionMargin.top + sectionMargin.bottom)
        let calendarGridMinY = columnHeaderHeight + contentsMargin.top
        let calendarContentMinX = rowHeaderWidth + contentsMargin.left + sectionMargin.left
        let calendarContentMinY = columnHeaderHeight + contentsMargin.top + sectionMargin.top
        let rowHeaderMinX = fmax(collectionView!.contentOffset.x, 0)
        
        // Current time line
        var hasTimeLineInAllSections = false
        sectionIndexes.enumerate(_:) { (section, stop) in
            let indexPath = IndexPath(row: 0, section: section)
            //  Only show current time line in today section
            if dateForColumnHeader(at: indexPath).isToday {
                let timeY = calendarContentMinY + nearbyint(CGFloat(currentTimeComponents.hour!) * hourHeight
                    + CGFloat(currentTimeComponents.minute!) * minuteHeight)
                let sectionMinX = calendarContentMinX + sectionWidth * CGFloat(section)
                let currentTimeHorizontalGridlineMinY = timeY - nearbyint(defaultGridThickness / 2.0) - defaultCurrentTimeLineHeight/2
                (attributes, currentTimeLineAttributes) = layoutAttributesForDecorationView(at: IndexPath(item: 0, section: section),
                                                                                            ofKind: DecorationViewKinds.currentTimeGridline,
                                                                                            withItemCache: currentTimeLineAttributes)
                attributes.frame = CGRect(x: sectionMinX, y: currentTimeHorizontalGridlineMinY, width: sectionWidth, height: defaultCurrentTimeLineHeight)
                attributes.zIndex = zIndexForElementKind(DecorationViewKinds.currentTimeGridline)
                //Remove some reused sections attributes
                currentTimeLineAttributes.removeAll()
                currentTimeLineAttributes[indexPath] = attributes
                hasTimeLineInAllSections = true
            }
        }
        if !hasTimeLineInAllSections {currentTimeLineAttributes.removeAll()}
        
    
        // Corner Header
        (attributes, cornerHeaderAttributes) = layoutAttributesForSupplemantaryView(at: IndexPath(row: 0, section: 0),
                                                                                    ofKind: SupplementaryViewKinds.cornerHeader,
                                                                                    withItemCache: cornerHeaderAttributes)
        attributes.frame = CGRect(origin: collectionView!.contentOffset, size: CGSize(width: rowHeaderWidth, height: columnHeaderHeight))
        attributes.zIndex = zIndexForElementKind(SupplementaryViewKinds.cornerHeader)
        
        // Row Header Background
        (attributes, rowHeaderBackgroundAttributes) = layoutAttributesForDecorationView(at: IndexPath(row: 0, section: 0),
                                                                                        ofKind: RowHeaderBackground.className,
                                                                                        withItemCache: rowHeaderBackgroundAttributes)
        attributes.frame = CGRect(x: rowHeaderMinX, y: collectionView!.contentOffset.y, width: rowHeaderWidth, height: collectionView!.frame.height)
        attributes.zIndex = zIndexForElementKind(DecorationViewKinds.rowHeaderBackground)
        
        // Row header
        for rowHeaderIndex in 0...24 {
            (attributes, rowHeaderAttributes) = layoutAttributesForSupplemantaryView(at: IndexPath(item: rowHeaderIndex, section: 0),
                                                                                     ofKind: SupplementaryViewKinds.rowHeader,
                                                                                     withItemCache: rowHeaderAttributes)
            let rowHeaderMinY = calendarContentMinY + hourHeight * CGFloat(rowHeaderIndex) - nearbyint(hourHeight / 2.0)
            attributes.frame = CGRect(x: rowHeaderMinX, y: rowHeaderMinY, width: rowHeaderWidth, height: hourHeight)
            attributes.zIndex = zIndexForElementKind(SupplementaryViewKinds.rowHeader)
        }
        
        // column header background
        (attributes, columnHeaderBackgroundAttributes) = layoutAttributesForDecorationView(at: IndexPath(row: 0, section: 0),
                                                                                           ofKind: DecorationViewKinds.columnHeaderBackground,
                                                                                           withItemCache: columnHeaderBackgroundAttributes)
        let attributesHeight = columnHeaderHeight + (collectionView!.contentOffset.y < 0 ? abs(collectionView!.contentOffset.y) : 0 )
        attributes.frame = CGRect(origin: collectionView!.contentOffset, size: CGSize(width: collectionView!.frame.width, height: attributesHeight))
        attributes.zIndex = zIndexForElementKind(DecorationViewKinds.columnHeaderBackground)
        
        // Column Header
        let columnHeaderMinY = fmax(collectionView!.contentOffset.y, 0.0)
        
        sectionIndexes.enumerate(_:) { (section, stop) in
            let sectionMinX = calendarContentMinX + sectionWidth * CGFloat(section)
            (attributes, columnHeaderAttributes) = layoutAttributesForSupplemantaryView(at: IndexPath(item: 0, section: section),
                                                                                        ofKind: SupplementaryViewKinds.columnHeader,
                                                                                        withItemCache: columnHeaderAttributes)
            attributes.frame = CGRect(x: sectionMinX, y: columnHeaderMinY, width: sectionWidth, height: columnHeaderHeight)
            attributes.zIndex = zIndexForElementKind(SupplementaryViewKinds.columnHeader)
            
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
            
            let itemMinX = nearbyint(sectionX + itemMargin.left)
            let itemMinY = nearbyint(startHourY + startMinuteY + calendarStartY + itemMargin.top)
            let itemMaxX = nearbyint(itemMinX + (sectionWidth - (itemMargin.left + itemMargin.right)))
            let itemMaxY = nearbyint(endHourY + endMinuteY + calendarStartY - itemMargin.bottom)
            
            attributes.frame = CGRect(x: itemMinX, y: itemMinY, width: itemMaxX - itemMinX, height: itemMaxY - itemMinY)
            attributes.zIndex = zIndexForElementKind(SupplementaryViewKinds.baseEventCell)
            sectionItemAttributes.append(attributes)
        }
        
        adjustItemsForOverlap(sectionItemAttributes, inSection: section, sectionMinX: sectionX,
                              currentSectionZ: zIndexForElementKind(SupplementaryViewKinds.baseEventCell))
    }
    
    func layoutVerticalGridLinesAttributes(section: Int, sectionX: CGFloat, calendarGridMinY: CGFloat, sectionHeight: CGFloat) {
        var attributes = UICollectionViewLayoutAttributes()
        
        (attributes, verticalGridlineAttributes) = layoutAttributesForDecorationView(at: IndexPath(item: 0, section: section),
                                                                                     ofKind: DecorationViewKinds.verticalGridline,
                                                                                     withItemCache: verticalGridlineAttributes)
        attributes.frame = CGRect(x: nearbyint(sectionX - defaultGridThickness / 2.0), y: calendarGridMinY,
                                  width: defaultGridThickness, height: sectionHeight)
        attributes.zIndex = zIndexForElementKind(DecorationViewKinds.verticalGridline)
    }
    
    func layoutHorizontalGridLinesAttributes(calendarStartX: CGFloat, calendarStartY: CGFloat) {
        var horizontalGridlineIndex = 0
        let calendarGridWidth = collectionViewContentSize.width - rowHeaderWidth - contentsMargin.left - contentsMargin.right
        var attributes = UICollectionViewLayoutAttributes()
        
        for hour in 0...24 {
            (attributes, horizontalGridlineAttributes) = layoutAttributesForDecorationView(at: IndexPath(item: horizontalGridlineIndex, section: 0),
                                                                                           ofKind: DecorationViewKinds.horizontalGridline,
                                                                                           withItemCache: horizontalGridlineAttributes)
            let horizontalGridlineXOffset = calendarStartX + sectionMargin.left
            let horizontalGridlineMinX = fmax(horizontalGridlineXOffset, collectionView!.contentOffset.x + horizontalGridlineXOffset)
            let horizontalGridlineMinY = nearbyint(calendarStartY + (hourHeight * CGFloat(hour))) - (defaultGridThickness / 2.0)
            let horizontalGridlineWidth = fmin(calendarGridWidth, collectionView!.frame.width)
            
            attributes.frame = CGRect(x: horizontalGridlineMinX, y: horizontalGridlineMinY,
                                      width: horizontalGridlineWidth, height: defaultGridThickness)
            attributes.zIndex = zIndexForElementKind(DecorationViewKinds.horizontalGridline)
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
                                                                                           ofKind: DecorationViewKinds.horizontalGridline,
                                                                                           withItemCache: horizontalGridlineAttributes)
            let horizontalGridlineMinY = nearbyint(calendarStartY + (divisionHeight * CGFloat(division)) - (defaultGridThickness / 2.0))
            attributes.frame = CGRect(x: calendarStartX, y: horizontalGridlineMinY, width: gridlineWidth, height: defaultGridThickness)
            attributes.alpha = 0.3
            attributes.zIndex = zIndexForElementKind(DecorationViewKinds.horizontalGridline)
            
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
        case SupplementaryViewKinds.columnHeader:
            return columnHeaderAttributes[indexPath]
        case SupplementaryViewKinds.rowHeader:
            return rowHeaderAttributes[indexPath]
        case SupplementaryViewKinds.cornerHeader:
            return cornerHeaderAttributes[indexPath]
            
        default:
            return nil
        }
    }
    
    override open func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        switch elementKind {
        case DecorationViewKinds.verticalGridline:
            return verticalGridlineAttributes[indexPath]
        case DecorationViewKinds.horizontalGridline:
            return horizontalGridlineAttributes[indexPath]
        case DecorationViewKinds.rowHeaderBackground:
            return rowHeaderBackgroundAttributes[indexPath]
        case DecorationViewKinds.columnHeaderBackground:
            return columnHeaderBackgroundAttributes[indexPath]
            
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
    
    /// Adjust items size when overlapping at same period
    open func adjustItemsForOverlap(_ sectionItemAttributes: [UICollectionViewLayoutAttributes], inSection: Int, sectionMinX: CGFloat, currentSectionZ: Int) {
        var adjustedAttributes = Set<UICollectionViewLayoutAttributes>()
        
        var sectionZ = currentSectionZ
        
        for itemAttributes in sectionItemAttributes {
            // If an item's already been adjusted, move on to the next one
            if adjustedAttributes.contains(itemAttributes) {
                continue
            }
            
            // Find the other items that overlap with this item
            var overlappingItems = [UICollectionViewLayoutAttributes]()
            let itemFrame = itemAttributes.frame
            
            overlappingItems.append(contentsOf: sectionItemAttributes.filter {
                if $0 != itemAttributes {
                    return itemFrame.intersects($0.frame)
                } else {
                    return false
                }
            })
            
            // If there's items overlapping, we need to adjust them
            if overlappingItems.count > 0 {
                // Add the item we're adjusting to the overlap set
                overlappingItems.insert(itemAttributes, at: 0)
                var minY = CGFloat.greatestFiniteMagnitude
                var maxY = CGFloat.leastNormalMagnitude
                
                for overlappingItemAttributes in overlappingItems {
                    if overlappingItemAttributes.frame.minY < minY {
                        minY = overlappingItemAttributes.frame.minY
                    }
                    if overlappingItemAttributes.frame.maxY > maxY {
                        maxY = overlappingItemAttributes.frame.maxY
                    }
                }
                
                // Determine the number of divisions needed (maximum number of currently overlapping items)
                var divisions = 1
                
                for currentY in stride(from: minY, to: maxY, by: 1) {
                    var numberItemsForCurrentY = 0
                    
                    for overlappingItemAttributes in overlappingItems {
                        if currentY >= overlappingItemAttributes.frame.minY &&
                            currentY < overlappingItemAttributes.frame.maxY {
                            numberItemsForCurrentY += 1
                        }
                    }
                    if numberItemsForCurrentY > divisions {
                        divisions = numberItemsForCurrentY
                    }
                }
                
                // Adjust the items to have a width of the section size divided by the number of divisions needed
                let divisionWidth = nearbyint(sectionWidth / CGFloat(divisions))
                var dividedAttributes = [UICollectionViewLayoutAttributes]()
                
                for divisionAttributes in overlappingItems {
                    let itemWidth = divisionWidth - itemMargin.left - itemMargin.right
                    
                    // It it hasn't yet been adjusted, perform adjustment
                    if !adjustedAttributes.contains(divisionAttributes) {
                        var divisionAttributesFrame = divisionAttributes.frame
                        divisionAttributesFrame.origin.x = sectionMinX + itemMargin.left
                        divisionAttributesFrame.size.width = itemWidth
                        
                        // Horizontal Layout
                        var adjustments = 1
                        for dividedItemAttributes in dividedAttributes {
                            if dividedItemAttributes.frame.intersects(divisionAttributesFrame) {
                                divisionAttributesFrame.origin.x = sectionMinX + ((divisionWidth * CGFloat(adjustments)) + itemMargin.left)
                                adjustments += 1
                            }
                        }
                        // Stacking (lower items stack above higher items, since the title is at the top)
                        divisionAttributes.zIndex = sectionZ
                        sectionZ += 1
                        
                        divisionAttributes.frame = divisionAttributesFrame
                        dividedAttributes.append(divisionAttributes)
                        adjustedAttributes.insert(divisionAttributes)
                    }
                }
            }
        }
    }
    
    func invalidateLayoutCache() {
        needsToPopulateAttributesForAllSections = true
        
        cachedDayDateComponents.removeAll()
        cachedStartTimeDateComponents.removeAll()
        cachedEndTimeDateComponents.removeAll()
        
        verticalGridlineAttributes.removeAll()
        horizontalGridlineAttributes.removeAll()
        columnHeaderAttributes.removeAll()
        columnHeaderBackgroundAttributes.removeAll()
        rowHeaderAttributes.removeAll()
        rowHeaderBackgroundAttributes.removeAll()
        cornerHeaderAttributes.removeAll()
        itemAttributes.removeAll()
        allAttributes.removeAll()
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let visibleSections = NSMutableIndexSet()
        NSIndexSet.init(indexesIn: NSRange(location: 0, length: collectionView!.numberOfSections))
            .enumerate(_:) { (section: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
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
    func rectForSection(_ section: Int) -> CGRect {
        return CGRect(x: rowHeaderWidth + sectionWidth * CGFloat(section), y: 0,
                      width: sectionWidth, height: collectionViewContentSize.height)
    }
    
    // MARK: - Delegate Wrapper
    func daysForSection(_ section: Int) -> DateComponents {
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
    
    func startTimeForIndexPath(_ indexPath: IndexPath) -> DateComponents {
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
    
    func endTimeForIndexPath(_ indexPath: IndexPath) -> DateComponents {
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
    
    func scrollCollectionViewToCurrentTime() {
        let y = max(0, min(CGFloat(Calendar.current.component(.hour, from: Date())) * hourHeight - collectionView!.frame.height / 2 + columnHeaderHeight,
                           collectionView!.contentSize.height - collectionView!.frame.height))
        
        let tempDelegate = collectionView!.delegate
        collectionView!.delegate = nil
        self.collectionView!.contentOffset = CGPoint(x: self.collectionView!.contentOffset.x, y: y)
        collectionView!.delegate = tempDelegate
    }
    
    public func dateForTimeRowHeader(at indexPath: IndexPath) -> Date {
        var components = daysForSection(indexPath.section)
        components.hour = indexPath.item
        return Calendar.current.date(from: components)!
    }
    
    public func dateForColumnHeader(at indexPath: IndexPath) -> Date {
        let day = delegate?.collectionView(collectionView!, layout: self, dayForSection: indexPath.section)
        return Calendar.current.startOfDay(for: day!)
    }
   
    // MARK: - z index
    open func zIndexForElementKind(_ kind: String) -> Int {
        switch kind {
        case SupplementaryViewKinds.cornerHeader:
            return minOverlayZ + 9
        case SupplementaryViewKinds.rowHeader:
            return minOverlayZ + 8
        case DecorationViewKinds.rowHeaderBackground:
            return minOverlayZ + 7
        case SupplementaryViewKinds.columnHeader:
            return minOverlayZ + 6
        case DecorationViewKinds.columnHeaderBackground:
            return minOverlayZ + 5
        case DecorationViewKinds.currentTimeGridline:
            return minOverlayZ + 4
        case DecorationViewKinds.horizontalGridline:
            return minBackgroundZ + 3
        case DecorationViewKinds.verticalGridline:
            return minBackgroundZ + 2
        default:
            return minCellZ
        }
    }
}
