//
//  CustomWeekView.swift
//  JZCalendarWeekViewExample
//
//  Created by Jeff Zhang on 23/4/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit
import JZCalendarWeekView

/// Custom grid line and row header & Not All Day
class CustomWeekView: JZBaseWeekView {
    
    override func registerViewClasses() {
        super.registerViewClasses()
        
        self.collectionView.register(UINib(nibName: EventCell.className, bundle: nil), forCellWithReuseIdentifier: EventCell.className)
        self.flowLayout.register(BlackGridLine.self, forDecorationViewOfKind: JZDecorationViewKinds.verticalGridline)
        self.flowLayout.register(BlackGridLine.self, forDecorationViewOfKind: JZDecorationViewKinds.horizontalGridline)
        self.collectionView.register(HourRowHeader.self, forSupplementaryViewOfKind: JZSupplementaryViewKinds.rowHeader, withReuseIdentifier: HourRowHeader.className)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let date = flowLayout.dateForColumnHeader(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCell.className, for: indexPath) as! EventCell
        cell.configureCell(event: allEventsBySection[date]![indexPath.row] as! DefaultEvent)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == JZSupplementaryViewKinds.rowHeader {
            let rowHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HourRowHeader.className, for: indexPath) as! HourRowHeader
            rowHeader.updateView(date: flowLayout.timeForRowHeader(at: indexPath))
            return rowHeader
        }
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedEvent = getCurrentEvent(with: indexPath) as! DefaultEvent
        ToastUtil.toastMessageInTheMiddle(message: selectedEvent.title)
    }
}
