//
//  JZLongPressWeekView.swift
//  JZCalendarWeekView
//
//  Created by Jeff Zhang on 26/4/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit

open class JZLongPressWeekView: JZBaseWeekView {
    
    public enum LongPressType {
        case none
        case addNew
        case move
    }
    
    var longPressTypes: [LongPressType]!
    var currentLongPressType: LongPressType = .none
    var longPressView: UIView!
    var longPressTimeLabel: UILabel!
    var currentMovingCell: UICollectionViewCell!
    
    public var moveTimeMinInterval: Int = 15
    public var addNewEventDuration: Int = 60
    public var timeLabelFont: UIFont = UIFont.systemFont(ofSize: 14)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupGestures()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGestures() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressToAddOrMoveEvents(_:)))
        longPressGesture.delegate = self
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    
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
        } else if point.y > longPressBottomMarginY - 10 && !isScrolling {
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
        // must set initial contentoffset because willBeginDragging will not be called
        initialContentOffset = collectionView.contentOffset
    }
    
    
    // TimeMinInterval is to identify the minimum time interval(Minute) when scrolling (minimum value is 1)
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
    
    
    open func initLongPressView(selectedCell: UICollectionViewCell?, type: LongPressType) -> UIView {
        
        let longPressView = type == .move ? getMoveLongPressView(selectedCell: selectedCell!) : getAddNewLongPressView()
        longPressView.clipsToBounds = false
        
        //timeText width will change from 00:00 - 24:00, and for each time the length will be different
        //add 5 to ensure the max width
        let labelHeight: CGFloat = 15
        let textWidth = UILabel.getLabelWidth(labelHeight, font: timeLabelFont, text: "23:59") + 5
        let timeLabelWidth = max(bounds.width, textWidth)
        longPressTimeLabel = UILabel(frame: CGRect(x: 0, y: -labelHeight, width: timeLabelWidth, height: labelHeight))
        longPressTimeLabel.font = UIFont.systemFont(ofSize: 14)
        longPressTimeLabel.textColor = UIColor.gray
        longPressView.addSubview(longPressTimeLabel)
        return longPressView
    }
    
    /// The default way to get move type longPressView is create a snapshot for the selectedCell.
    /// Override this function to customise your own Move longPressView
    /// - Parameter selectedCell: The long pressed cell
    /// - Returns: Move LongPressView (dragging with your finger when move event)
    open func getMoveLongPressView(selectedCell: UICollectionViewCell) -> UIView {
        let cellSnapshot = selectedCell.snapshotView(afterScreenUpdates: true)
        let longPressView = UIView(frame: selectedCell.frame)
        longPressView.addSubview(cellSnapshot!)
        cellSnapshot?.setAnchorConstraintsFullSizeTo(view: longPressView)
        return longPressView
    }
    
    /// Complete this function to create custom addNew longPressView, when add new gesture recognised
    ///
    /// - Returns: Custom AddNew longPressView (dragging with your finger when add new event)
    open func getAddNewLongPressView() -> UIView {
        preconditionFailure("This method must be overridden")
    }
    
    open func didEndAddNewLongPress() {
        
    }
    
    open func didEndMoveLongPress() {
         currentMovingCell.isHidden = false
    }
}

//Long press Gesture methods
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
    
    @objc func longPressToAddOrMoveEvents(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        let pointInSelfView = gestureRecognizer.location(in: self)
        let pointInCollectionView = gestureRecognizer.location(in: collectionView)
        
        let state = gestureRecognizer.state
        
        let date = getDateForPoint(pointCollectionView: pointInCollectionView, pointSelfView: pointInSelfView)
        let startDate = getLongpressStartTime(date: date, dateInSection: getDateForX(xCollectionView: pointInCollectionView.x, xSelfView: pointInSelfView.x), timeMinInterval: moveTimeMinInterval)
        
        if currentLongPressType == LongPressType.none {
            if let indexPath = collectionView.indexPathForItem(at: pointInCollectionView) {
                // Can add some conditions for allowing only few types of cells can be moved
                currentLongPressType = .move
                currentMovingCell = collectionView.cellForItem(at: indexPath)
            } else {
                currentLongPressType = .addNew
            }
        }
        
        let viewHeight = flowLayout.defaultHourHeight * CGFloat(addNewEventDuration/60)
        
        if state == .began {
            
            longPressView = initLongPressView(selectedCell: currentMovingCell, type: currentLongPressType)
            longPressView.center = CGPoint(x: pointInSelfView.x, y: pointInSelfView.y + viewHeight/2)
            longPressView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.addSubview(longPressView)
            
            if currentLongPressType == .move {
                currentMovingCell.isHidden = true
            }
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: .curveEaseOut,
                           animations: { self.longPressView.transform = CGAffineTransform.identity }, completion: nil)
            
        } else if state == .changed {
            
            let yPoint = max(pointInSelfView.y, longPressTopMarginY) + viewHeight/2
            
            longPressView.center = CGPoint(x: pointInSelfView.x, y: yPoint)
            
        } else if state == .cancelled {
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
                self.longPressView.alpha = 0
            }, completion: {
                (finished: Bool) -> Void in
                self.longPressView.removeFromSuperview()
            })
            
        } else if state == .ended {
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut,
                           animations: { self.longPressView.alpha = 0 },
                           completion: { (finished: Bool) -> Void in
                            self.longPressView!.removeFromSuperview()})
            
            if self.currentLongPressType == .addNew {
                didEndAddNewLongPress()
            } else {
               didEndMoveLongPress()
            }
        }
        
        if state == .began || state == .changed {
            updateTimeLabel(time: startDate, point: pointInSelfView)
            updateScroll(point: pointInSelfView)
        }
        
        if state == .ended || state == .cancelled {
            currentLongPressType = LongPressType.none
            currentMovingCell = nil
            return
        }
    }
    
}
