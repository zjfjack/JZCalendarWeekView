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
    ///   - movingCell: the moving (existed, editing) cell
    ///   - startDate: the startDate of the event when gesture ends
    func weekView(_ weekView: JZLongPressWeekView, movingCell: UICollectionViewCell, didEndMoveLongPressAt startDate: Date)
    
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
    public func weekView(_ weekView: JZLongPressWeekView, movingCell: UICollectionViewCell, didEndMoveLongPressAt startDate: Date) {}
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
    
    private var isLongPressing: Bool = false
    private var currentLongPressType: LongPressType!
    private var longPressView: UIView!
    private var currentMovingCell: UICollectionViewCell!
    
    public weak var longPressDelegate: JZLongPressViewDelegate?
    public weak var longPressDataSource: JZLongPressViewDataSource?
    
    // You can modify these properties below
    public var longPressTypes: [LongPressType]!
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
    
    /// The most top Y in the collectionView that you want longPress gesture enable.
    /// If you customise some decoration and supplementry views on top, **must** override this variable
    open var longPressTopMarginY: CGFloat {
        return flowLayout.columnHeaderHeight
    }
    
    /// The most bottom Y in the collectionView that you want longPress gesture enable.
    /// If you customise some decoration and supplementry views on bottom, **must** override this variable
    open var longPressBottomMarginY: CGFloat{
        return frame.height
    }
    
    
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
    private func updateTimeLabel(time: Date, point: CGPoint) {
        longPressTimeLabel.text = time.getTimeIgnoreSecondsFormat()
        
        let isOutsideRowHeader = point.x - longPressView.frame.width/2 < flowLayout.rowHeaderWidth
        longPressTimeLabel.textAlignment = isOutsideRowHeader ? .right : .left
        
        let labelHeight = longPressTimeLabel.frame.height
        let isBeyondTopMargin = point.y - labelHeight < longPressTopMarginY
        let yPosition = isBeyondTopMargin ? longPressView.frame.height : -labelHeight
        if longPressTimeLabel.frame.origin.y != yPosition {
            longPressTimeLabel.frame.origin.y = yPosition
        }
    }
    
    /// When dragging the longPressView, the collectionView should scroll with the drag point
    private func updateScroll(point: CGPoint) {
        // vertical
        if point.y < longPressTopMarginY + 10 && !isScrolling {
            isScrolling = true
            scrollingTo(direction: .up)
        } else if point.y > longPressBottomMarginY - 30 && !isScrolling {
            isScrolling = true
            scrollingTo(direction: .down)
        }
        // horizontal
        if point.x < flowLayout.rowHeaderWidth && !isScrolling {
            isScrolling = true
            scrollingTo(direction: .right)
            
        } else if frame.width - point.x < 20 && !isScrolling {
            isScrolling = true
            scrollingTo(direction: .left)
        }
    }
    
    private func scrollingTo(direction: ScrollDirection) {
        let currentOffset = collectionView.contentOffset
        let maxOffsetY = collectionView.contentSize.height - collectionView.bounds.height + collectionView.contentInset.bottom
        
        if direction == .up || direction == .down {
            var yOffset = CGFloat()
            
            // TODO: NOT SURE WHY NEED THIS LINE
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
            // scrollview didEndAnimation will not set isScrolling, should set by ourselves
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
        // must set initial contentoffset because willBeginDragging will not be called
        initialContentOffset = collectionView.contentOffset
    }
    
    
    /// Calculate the expected start date with timeMinInterval
    private func getLongPressStartDate(date: Date, dateInSection: Date, timeMinInterval: Int) -> Date {
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
    
    /// Initialise the long press view with longPressTimeLabel
    open func initLongPressView(selectedCell: UICollectionViewCell?, type: LongPressType, startDate: Date) -> UIView {
        
        let longPressView = type == .move ? longPressDataSource!.weekView(self, movingCell: selectedCell!, viewForMoveLongPressAt: startDate) :
                                            longPressDataSource!.weekView(self, viewForAddNewLongPressAt: startDate)
        longPressView.clipsToBounds = false
        
        //timeText width will change from 00:00 - 24:00, and for each time the length will be different
        //add 5 to ensure the max width
        let labelHeight: CGFloat = 15
        let textWidth = UILabel.getLabelWidth(labelHeight, font: longPressTimeLabel.font, text: "23:59") + 5
        let timeLabelWidth = max(selectedCell?.bounds.width ?? flowLayout.sectionWidth, textWidth)
        longPressTimeLabel.frame = CGRect(x: 0, y: -labelHeight, width: timeLabelWidth, height: labelHeight)
        longPressView.addSubview(longPressTimeLabel)
        return longPressView
    }
}

// Long press Gesture methods
extension JZLongPressWeekView: UIGestureRecognizerDelegate {
    
    // Override this function to customise gesture begin conditions
    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let pointInSelfView = gestureRecognizer.location(in: self)
        let pointInCollectionView = gestureRecognizer.location(in: collectionView)
        
        if gestureRecognizer.state == .possible {
            // Long press on rowheader or beyond top margin should not begin
            let isOutsideBeginArea = pointInSelfView.x <= flowLayout.rowHeaderWidth || pointInSelfView.y < longPressTopMarginY
            if isOutsideBeginArea { return false  }
        }
        // Long press should not begin if no events at long press position and addNew not required
        if collectionView.indexPathForItem(at: pointInCollectionView) == nil && !longPressTypes.contains(LongPressType.addNew) {
            return false
        }
        
        return true
    }
    
    @objc private func handleLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        let pointInSelfView = gestureRecognizer.location(in: self)
        let pointInCollectionView = gestureRecognizer.location(in: collectionView)
        
        let state = gestureRecognizer.state
        
        let date = getDateForPoint(pointCollectionView: pointInCollectionView, pointSelfView: pointInSelfView)
        let startDate = getLongPressStartDate(date: date, dateInSection: getDateForX(xCollectionView: pointInCollectionView.x, xSelfView: pointInSelfView.x), timeMinInterval: moveTimeMinInterval)
        
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
        
        let viewSize = currentLongPressType == .move ? currentMovingCell.frame.size : CGSize(width: flowLayout.sectionWidth, height: flowLayout.defaultHourHeight * CGFloat(addNewDurationMins/60))
        
        if state == .began {
            
            longPressView = initLongPressView(selectedCell: currentMovingCell, type: currentLongPressType, startDate: startDate)
            longPressView.frame.size = viewSize
            longPressView.center = CGPoint(x: pointInSelfView.x, y: pointInSelfView.y + viewSize.height/2)
            longPressView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.addSubview(longPressView)
            
            if currentLongPressType == .move {
                currentMovingCell.isHidden = true
            }
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: .curveEaseOut,
                           animations: { self.longPressView.transform = CGAffineTransform.identity }, completion: nil)
            
        } else if state == .changed {
            
            let yPoint = max(pointInSelfView.y, longPressTopMarginY) + viewSize.height/2
            longPressView.center = CGPoint(x: pointInSelfView.x, y: yPoint)
            
        } else if state == .cancelled {
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
                self.longPressView.alpha = 0
            }, completion: {
                (finished: Bool) -> Void in
                self.longPressView.removeFromSuperview()
            })
            
            longPressDelegate?.weekView(self, longPressType: currentLongPressType, didCancelLongPressAt: startDate)
            
        } else if state == .ended {
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut,
                           animations: { self.longPressView.alpha = 0 },
                           completion: { (finished: Bool) -> Void in
                            self.longPressView.removeFromSuperview()})
            
            if currentLongPressType == .addNew {
                longPressDelegate?.weekView(self, didEndAddNewLongPressAt: startDate)
            } else if currentLongPressType == .move {
                longPressDelegate?.weekView(self, movingCell: currentMovingCell, didEndMoveLongPressAt: startDate)
                currentMovingCell.isHidden = false
            }
        }
        
        if state == .began || state == .changed {
            updateTimeLabel(time: startDate, point: pointInSelfView)
            updateScroll(point: pointInSelfView)
        }
        
        if state == .ended || state == .cancelled {
            longPressTimeLabel.removeFromSuperview()
            isLongPressing = false
            return
        }
    }
    
}
