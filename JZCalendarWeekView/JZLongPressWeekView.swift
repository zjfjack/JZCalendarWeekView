//
//  JZLongPressWeekView.swift
//  JZCalendarWeekView
//
//  Created by Jeff Zhang on 26/4/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit

public protocol JZLongPressViewDelegate: class {

    /// When addNew long press gesture ends, this function will be called.
    /// You should handle what should be done after creating a new event.
    /// - Parameters:
    ///   - weekView: current long pressed JZLongPressWeekView
    ///   - startDate: the startDate of the event when gesture ends
    func weekView(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date)

    /// When Move long press gesture ends, this function will be called.
    /// You should handle what should be done after editing (moving) a existed event.
    /// - Parameters:
    ///   - weekView: current long pressed JZLongPressWeekView
    ///   - editingEvent: the moving (existed, editing) event
    ///   - startDate: the startDate of the event when gesture ends
    func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndMoveLongPressAt startDate: Date)

    /// Sometimes the longPress will be cancelled because some curtain reason.
    /// Normally this function no need to be implemented.
    /// - Parameters:
    ///   - weekView: current long pressed JZLongPressWeekView
    ///   - longPressType: the long press type when gusture cancels
    ///   - startDate: the startDate of the event when gesture cancels
    func weekView(_ weekView: JZLongPressWeekView, longPressType: JZLongPressWeekView.LongPressType, didCancelLongPressAt startDate: Date)
}

public protocol JZLongPressViewDataSource: class {
    /// Implement this function to customise your own AddNew longPressView
    /// - Parameters:
    ///   - weekView: current long pressed JZLongPressWeekView
    ///   - startDate: the startDate when initialise the longPressView (if you want, you can get the section with startDate)
    /// - Returns: AddNew type of LongPressView (dragging with your finger when move this view)
    func weekView(_ weekView: JZLongPressWeekView, viewForAddNewLongPressAt startDate: Date) -> UIView

    /// The default way to get move type longPressView is create a snapshot for the selectedCell.
    /// Implement this function to customise your own Move longPressView
    /// - Parameters:
    ///   - weekView: current long pressed JZLongPressWeekView
    ///   - movingCell: the exsited cell currently is moving
    ///   - startDate: the startDate when initialise the longPressView
    /// - Returns: Move type of LongPressView (dragging with your finger when move event)
    func weekView(_ weekView: JZLongPressWeekView, movingCell: UICollectionViewCell, viewForMoveLongPressAt startDate: Date) -> UIView
}

extension JZLongPressViewDelegate {
    // Keep them optional
    public func weekView(_ weekView: JZLongPressWeekView, longPressType: JZLongPressWeekView.LongPressType, didCancelLongPressAt startDate: Date) {}
    public func weekView(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date) {}
    public func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndMoveLongPressAt startDate: Date) {}
}

extension JZLongPressViewDataSource {
    // Default snapshot method
    public func weekView(_ weekView: JZLongPressWeekView, movingCell: UICollectionViewCell, viewForMoveLongPressAt startDate: Date) -> UIView {
        let cellSnapshot = movingCell.snapshotView(afterScreenUpdates: true)
        let longPressView = UIView(frame: movingCell.frame)
        longPressView.addSubview(cellSnapshot!)
        cellSnapshot?.setAnchorConstraintsFullSizeTo(view: longPressView)
        return longPressView
    }

}

open class JZLongPressWeekView: JZBaseWeekView {

    public enum LongPressType {
        /// when long press position is not on a existed event, this type will create a new event view allowing user to move
        case addNew
        /// when long press position is on a existed event, this type will allow user to move the existed event
        case move
    }

    /// This structure is used to save editing information before reusing collectionViewCell (Type Move used only)
    private struct CurrentEditingInfo {
        /// The editing event when move type long press(used to be currentMovingCell, it is a reference of cell but item will be reused in CollectionView!!)
        var event: JZBaseEvent!
        /// The editing cell original size, get it from the long press status began
        var cellSize: CGSize!
        /// (REPLACED THIS ONE WITH EVENT ID NOW) Save current indexPath to check whether a cell is the previous one ()
        var indexPath: IndexPath!
        /// Save current all changed opacity cell contentViews to change them back when end or cancel longPress, have to save them because of cell reusage
        var allOpacityContentViews = [UIView]()
    }
    /// When moving the longPress view, if it causes the collectionView scrolling
    private var isScrolling: Bool = false
    private var isLongPressing: Bool = false
    private var currentLongPressType: LongPressType!
    private var longPressView: UIView!
    private var currentEditingInfo = CurrentEditingInfo()
    /// Get this value when long press began and save the current relative X and Y value until it ended or cancelled
    private var pressPosition: (xToViewLeft: CGFloat, yToViewTop: CGFloat)?

    public weak var longPressDelegate: JZLongPressViewDelegate?
    public weak var longPressDataSource: JZLongPressViewDataSource?

    // You can modify these properties below
    public var longPressTypes: [LongPressType] = [LongPressType]()
    /// It is used to identify the minimum time interval(Minute) when dragging the event view (minimum value is 1, maximum is 60)
    public var moveTimeMinInterval: Int = 15
    /// For an addNew event, the event duration mins determine the add new event duration and height
    public var addNewDurationMins: Int = 120
    /// The longPressTimeLabel along with longPressView, can be customised
    public var longPressTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.gray
        return label
    }()
    /// The moving cell contentView layer opacity (when you move the existing cell, the previous cell will be translucent)
    /// If your cell background alpha below this value, you should decrease this value as well
    public var movingCellOpacity: Float = 0.6

    /// The most top Y in the collectionView that you want longPress gesture enable.
    /// If you customise some decoration and supplementry views on top, **must** override this variable
    open var longPressTopMarginY: CGFloat { return flowLayout.columnHeaderHeight + flowLayout.allDayHeaderHeight }
    /// The most bottom Y in the collectionView that you want longPress gesture enable.
    /// If you customise some decoration and supplementry views on bottom, **must** override this variable
    open var longPressBottomMarginY: CGFloat { return frame.height }
    /// The most left X in the collectionView that you want longPress gesture enable.
    /// If you customise some decoration and supplementry views on left, **must** override this variable
    open var longPressLeftMarginX: CGFloat { return flowLayout.rowHeaderWidth }
    /// The most right X in the collectionView that you want longPress gesture enable.
    /// If you customise some decoration and supplementry views on right, **must** override this variable
    open var longPressRightMarginX: CGFloat { return frame.width }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestures()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupGestures()
    }

    private func setupGestures() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPressGesture(_:)))
        longPressGesture.delegate = self
        collectionView.addGestureRecognizer(longPressGesture)
    }

    /// Updating time label in longPressView during dragging
    private func updateTimeLabel(time: Date, pointInSelfView: CGPoint) {
        updateTimeLabelText(time: time)
        updateTimeLabelPosition(pointInSelfView: pointInSelfView)
    }

    /// Update time label content, this method can be overridden
    open func updateTimeLabelText(time: Date) {
        longPressTimeLabel.text = time.getTimeIgnoreSecondsFormat()
    }

    /// Update the position for the time label
    private func updateTimeLabelPosition(pointInSelfView: CGPoint) {
        let isOutsideLeftMargin = pointInSelfView.x - pressPosition!.xToViewLeft < longPressLeftMarginX
        longPressTimeLabel.textAlignment = isOutsideLeftMargin ? .right : .left

        let labelHeight = longPressTimeLabel.frame.height
        let isBeyondTopMargin = pointInSelfView.y - pressPosition!.yToViewTop - labelHeight < longPressTopMarginY
        let yPosition = isBeyondTopMargin ? longPressView.frame.height : -labelHeight
        if longPressTimeLabel.frame.origin.y != yPosition {
            longPressTimeLabel.frame.origin.y = yPosition
        }
    }

    /// When dragging the longPressView, the collectionView should scroll with the drag point.
    /// - The logic of vertical scroll is top scroll depending on **longPressView top** to longPressTopMarginY, bottom scroll denpending on **finger point** to LongPressBottomMarginY.
    /// - The logic of horizontal scroll is left scroll depending on **finger point** to longPressLeftMarginY, bottom scroll denpending on **finger point** to LongPressRightMarginY.
    private func updateScroll(pointInSelfView: CGPoint) {
        if isScrolling { return }

        // vertical
        if pointInSelfView.y - pressPosition!.yToViewTop < longPressTopMarginY + 10 {
            isScrolling = true
            scrollingTo(direction: .up)
            return
        } else if pointInSelfView.y > longPressBottomMarginY - 40 {
            isScrolling = true
            scrollingTo(direction: .down)
            return
        }
        // horizontal
        if pointInSelfView.x < longPressLeftMarginX + 10 {
            isScrolling = true
            scrollingTo(direction: .right)
            return
        } else if pointInSelfView.x > longPressRightMarginX - 20 {
            isScrolling = true
            scrollingTo(direction: .left)
            return
        }
    }

    /*
     NOTICE: Existing issue: In some scenarios, longPress to edge cannot trigger collectionView scrolling
     Generally, it is because isScrolling set true previously but doesn't set false back, which cause cannot scroll next time because isScrolling is true
        1. In section scroll, when keep longPressing and scrolling, sometimes it will become unscrollable. (Should be caused by forceReload async, page scroll got enough time to async reload)
        2. In both scroll types, if you end longPress at the left or right edge when collectionView is scrolling, it might cause isScrolling cannot set back to false either.
     This issue exists before 0.7.0 (not caused by pagination redesign), will be fixed when async forceReload issue has been resolved
    */
    private func scrollingTo(direction: LongPressScrollDirection) {
        let currentOffset = collectionView.contentOffset
        let minOffsetY: CGFloat = 0, maxOffsetY = collectionView.contentSize.height - collectionView.bounds.height

        if direction == .up || direction == .down {
            let yOffset: CGFloat

            if direction == .up {
                yOffset = max(minOffsetY, currentOffset.y - 50)
                collectionView.setContentOffset(CGPoint(x: currentOffset.x, y: yOffset), animated: true)
            } else {
                yOffset = min(maxOffsetY, currentOffset.y + 50)
                collectionView.setContentOffset(CGPoint(x: currentOffset.x, y: yOffset), animated: true)
            }
            // scrollview didEndAnimation will not set isScrolling, should be set manually
            if yOffset == minOffsetY || yOffset == maxOffsetY {
                isScrolling = false
            }

        } else {
            var contentOffsetX: CGFloat
            switch scrollType! {
            case .sectionScroll:
                let scrollSections: CGFloat = direction == .left ? -1 : 1
                contentOffsetX = currentOffset.x - flowLayout.sectionWidth! * scrollSections
            case .pageScroll:
                contentOffsetX = direction == .left ? contentViewWidth * 2 : 0
            }
            // Take the horizontal scrollable edges into account
            let contentOffsetXWithScrollableEdges = min(max(contentOffsetX, scrollableEdges.leftX ?? -1), scrollableEdges.rightX ?? CGFloat.greatestFiniteMagnitude)
            if contentOffsetXWithScrollableEdges == currentOffset.x {
                // scrollViewDidEndScrollingAnimation will not be called
                isScrolling = false
            } else {
                collectionView.setContentOffset(CGPoint(x: contentOffsetXWithScrollableEdges, y: currentOffset.y), animated: true)
            }
        }
    }

    /// Calculate the expected start date with timeMinInterval
    func getLongPressStartDate(date: Date, dateInSection: Date, timeMinInterval: Int) -> Date {
        let daysBetween = Date.daysBetween(start: dateInSection, end: date, ignoreHours: true)
        let startDate: Date

        if daysBetween == 1 {
            // Below the bottom set as the following day
            startDate = date.startOfDay
        } else if daysBetween == -1 {
            // Beyond the top set as the current day
            startDate = dateInSection.startOfDay
        } else {
            let currentMin = Calendar.current.component(.minute, from: date)
            // Choose previous time interval (currentMin/timeMinInterval = Int)
            let minValue = (currentMin/timeMinInterval) * timeMinInterval
            startDate = date.set(minute: minValue)
        }
        return startDate
    }

    /// Initialise the long press view with longPressTimeLabel.
    open func initLongPressView(selectedCell: UICollectionViewCell?, type: LongPressType, startDate: Date) -> UIView {

        let longPressView = type == .move ? longPressDataSource!.weekView(self, movingCell: selectedCell!, viewForMoveLongPressAt: startDate) :
                                            longPressDataSource!.weekView(self, viewForAddNewLongPressAt: startDate)
        longPressView.clipsToBounds = false

        // timeText width will change from 00:00 - 24:00, and for each time the length will be different
        // add 5 to ensure the max width
        let labelHeight: CGFloat = 15
        let textWidth = UILabel.getLabelWidth(labelHeight, font: longPressTimeLabel.font, text: "23:59") + 5
        let timeLabelWidth = max(selectedCell?.bounds.width ?? flowLayout.sectionWidth, textWidth)
        longPressTimeLabel.frame = CGRect(x: 0, y: -labelHeight, width: timeLabelWidth, height: labelHeight)
        longPressView.addSubview(longPressTimeLabel)
        longPressView.setDefaultShadow()
        return longPressView
    }

    /// Overload for base class with left and right margin check for LongPress
    open func getDateForPointX(xCollectionView: CGFloat, xSelfView: CGFloat) -> Date {
        let date = self.getDateForPointX(xCollectionView)
        // when isScrolling equals true, means it will scroll to previous date
        if xSelfView < longPressLeftMarginX && isScrolling == false {
            // should add one date to put the view inside current page
            return date.add(component: .day, value: 1)
        } else if xSelfView > longPressRightMarginX && isScrolling == false {
            // normally this condition will not enter
            // should substract one date to put the view inside current page
            return date.add(component: .day, value: -1)
        } else {
            return date
        }
    }

    /// Overload for base class with modified date for X
    open func getDateForPoint(pointCollectionView: CGPoint, pointSelfView: CGPoint) -> Date {
        let yearMonthDay = getDateForPointX(xCollectionView: pointCollectionView.x, xSelfView: pointSelfView.x)
        let hourMinute = getDateForPointY(pointCollectionView.y)
        return yearMonthDay.set(hour: hourMinute.0, minute: hourMinute.1, second: 0)
    }

    // Only being called when setContentOffset ends animition by scrollingTo method
    // scrollViewDidEndScrollingAnimation won't be called in JZBaseWeekView, then should load page here
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // vertical scroll should not load page, handled in loadPage method
        loadPage()
        isScrolling = false
    }

    // Following three functions are used to Handle collectionView items reusued

    /// when the previous cell is reused, have to find current one
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard isLongPressing == true && currentLongPressType == .move else { return }

        let cellContentView = cell.contentView

        if isOriginalMovingCell(cell) {
            cellContentView.layer.opacity = movingCellOpacity
            if !currentEditingInfo.allOpacityContentViews.contains(cellContentView) {
                currentEditingInfo.allOpacityContentViews.append(cellContentView)
            }
        } else {
            cellContentView.layer.opacity = 1
            if let index = currentEditingInfo.allOpacityContentViews.firstIndex(where: {$0 == cellContentView}) {
                currentEditingInfo.allOpacityContentViews.remove(at: index)
            }
        }
    }

    /// Use the event id to check the cell item is the original cell
    private func isOriginalMovingCell(_ cell: UICollectionViewCell) -> Bool {
        if let cell = cell as? JZLongPressEventCell {
            return cell.event.id == currentEditingInfo.event.id
        } else {
            return false
        }
    }

     /*** Because of reusability, we set some cell contentViews to translucent, then when those views are reused, if you don't scroll back
     the willDisplayCell will not be called, then those reused contentViews will be translucent and cannot be found */
    /// Get the current moving cells to change to alpha (crossing days will have more than one cells)
    private func getCurrentMovingCells() -> [UICollectionViewCell] {
        var movingCells = [UICollectionViewCell]()
        for cell in collectionView.visibleCells {
            if isOriginalMovingCell(cell) {
                movingCells.append(cell)
            }
        }
        return movingCells
    }
}

// Long press Gesture methods
extension JZLongPressWeekView: UIGestureRecognizerDelegate {

    // Override this function to customise gesture begin conditions
    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let pointInSelfView = gestureRecognizer.location(in: self)
        let pointInCollectionView = gestureRecognizer.location(in: collectionView)

        if gestureRecognizer.state == .possible {
            // Long press on ouside margin area should not begin
            let isOutsideBeginArea = pointInSelfView.x < longPressLeftMarginX || pointInSelfView.x > longPressRightMarginX ||
                                     pointInSelfView.y < longPressTopMarginY || pointInSelfView.y > longPressBottomMarginY
            if isOutsideBeginArea { return false  }
        }

        let hasItemAtPoint = collectionView.indexPathForItem(at: pointInCollectionView) != nil

        // Long press should not begin if there are events at long press position and move not required
        if hasItemAtPoint && !longPressTypes.contains(LongPressType.move) {
            return false
        }

        // Long press should not begin if no events at long press position and addNew not required
        if !hasItemAtPoint && !longPressTypes.contains(LongPressType.addNew) {
            return false
        }

        return true
    }

    /// The basic longPressView position logic is moving with your finger's original position.
    /// - The Move type longPressView will keep the relative position during this longPress, that's how Apple Calendar did.
    /// - The AddNew type longPressView will be created centrally at your finger press position
    @objc private func handleLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {

        let pointInSelfView = gestureRecognizer.location(in: self)
        /// Used for get startDate of longPressView
        let pointInCollectionView = gestureRecognizer.location(in: collectionView)

        let state = gestureRecognizer.state
        var currentMovingCell: UICollectionViewCell!

        if isLongPressing == false {
            if let indexPath = collectionView.indexPathForItem(at: pointInCollectionView) {
                // Can add some conditions for allowing only few types of cells can be moved
                currentLongPressType = .move
                currentMovingCell = collectionView.cellForItem(at: indexPath)
            } else {
                currentLongPressType = .addNew
            }
            isLongPressing = true
        }

        // The startDate of the longPressView (the date of top Y in longPressView)
        var longPressViewStartDate: Date!

        // pressPosition is nil only when state equals began
        if pressPosition != nil {
            longPressViewStartDate = getLongPressViewStartDate(pointInCollectionView: pointInCollectionView, pointInSelfView: pointInSelfView)
        }

        if state == .began {

            currentEditingInfo.cellSize = currentLongPressType == .move ? currentMovingCell.frame.size : CGSize(width: flowLayout.sectionWidth, height: flowLayout.hourHeight * CGFloat(addNewDurationMins)/60)
            pressPosition = currentLongPressType == .move ? (pointInCollectionView.x - currentMovingCell.frame.origin.x, pointInCollectionView.y - currentMovingCell.frame.origin.y) :
                                                            (currentEditingInfo.cellSize.width/2, currentEditingInfo.cellSize.height/2)
            longPressViewStartDate = getLongPressViewStartDate(pointInCollectionView: pointInCollectionView, pointInSelfView: pointInSelfView)
            longPressView = initLongPressView(selectedCell: currentMovingCell, type: currentLongPressType, startDate: longPressViewStartDate)
            longPressView.frame.size = currentEditingInfo.cellSize
            longPressView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.addSubview(longPressView)

            longPressView.center = CGPoint(x: pointInSelfView.x - pressPosition!.xToViewLeft + currentEditingInfo.cellSize.width/2,
                                           y: pointInSelfView.y - pressPosition!.yToViewTop + currentEditingInfo.cellSize.height/2)
            if currentLongPressType == .move {
                currentEditingInfo.event = (currentMovingCell as! JZLongPressEventCell).event
                getCurrentMovingCells().forEach {
                    $0.contentView.layer.opacity = movingCellOpacity
                    currentEditingInfo.allOpacityContentViews.append($0.contentView)
                }
            }

            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: .curveEaseOut,
                           animations: { self.longPressView.transform = CGAffineTransform.identity }, completion: nil)

        } else if state == .changed {
            let topYPoint = max(pointInSelfView.y - pressPosition!.yToViewTop, longPressTopMarginY)
            longPressView.center = CGPoint(x: pointInSelfView.x - pressPosition!.xToViewLeft + currentEditingInfo.cellSize.width/2,
                                           y: topYPoint + currentEditingInfo.cellSize.height/2)

        } else if state == .cancelled {

            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
                self.longPressView.alpha = 0
            }, completion: { _ in
                self.longPressView.removeFromSuperview()
            })
            longPressDelegate?.weekView(self, longPressType: currentLongPressType, didCancelLongPressAt: longPressViewStartDate)

        } else if state == .ended {

            self.longPressView.removeFromSuperview()
            if currentLongPressType == .addNew {
                longPressDelegate?.weekView(self, didEndAddNewLongPressAt: longPressViewStartDate)
            } else if currentLongPressType == .move {
                longPressDelegate?.weekView(self, editingEvent: currentEditingInfo.event, didEndMoveLongPressAt: longPressViewStartDate)
            }
        }

        if state == .began || state == .changed {
            updateTimeLabel(time: longPressViewStartDate, pointInSelfView: pointInSelfView)
            updateScroll(pointInSelfView: pointInSelfView)
        }

        if state == .ended || state == .cancelled {
            longPressTimeLabel.removeFromSuperview()
            isLongPressing = false
            pressPosition = nil

            if currentLongPressType == .move {
                currentEditingInfo.allOpacityContentViews.forEach { $0.layer.opacity = 1 }
                currentEditingInfo.allOpacityContentViews.removeAll()
            }
            return
        }
    }

    /// used by handleLongPressGesture only
    private func getLongPressViewStartDate(pointInCollectionView: CGPoint, pointInSelfView: CGPoint) -> Date {
        let longPressViewTopDate = getDateForPoint(pointCollectionView: CGPoint(x: pointInCollectionView.x, y: pointInCollectionView.y - pressPosition!.yToViewTop), pointSelfView: pointInSelfView)
        let longPressViewStartDate = getLongPressStartDate(date: longPressViewTopDate, dateInSection: getDateForPointX(xCollectionView: pointInCollectionView.x, xSelfView: pointInSelfView.x), timeMinInterval: moveTimeMinInterval)
        return longPressViewStartDate
    }

}

extension JZLongPressWeekView {

    /// For indicating which direction should collectionView scroll to in LongPressWeekView
    enum LongPressScrollDirection {
        case up
        case down
        case left
        case right
    }

}
