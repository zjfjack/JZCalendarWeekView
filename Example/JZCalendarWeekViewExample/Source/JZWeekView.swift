//
//  JZWeekView.swift
//  JZCalendarViewExample
//
//  Created by Jeff Zhang on 4/4/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit
import JZCalendarWeekView

class JZWeekView: BaseWeekView {
    
    override func registerViewClasses() {
        super.registerViewClasses()
        
        self.collectionView.register(UINib(nibName: "SoloEventCell", bundle: nil), forCellWithReuseIdentifier: "SoloEventCell")
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let date = flowLayout.dateForColumnHeader(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SoloEventCell", for: indexPath) as! SoloEventCell
        cell.updateView(event: allEventsBySection[date]![indexPath.row] as! JZEvent)
        return cell
    }
    

}
