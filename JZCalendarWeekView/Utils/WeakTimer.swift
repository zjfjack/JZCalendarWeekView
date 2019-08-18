//
//  WeakTimer.swift
//  JZCalendarWeekView
//
//  Created by Jeff Zhang on 14/9/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

// Thanks for https://gist.github.com/Visput/d40c5ceaefbc50c7377597ba0865c9df

import Foundation

final class WeakTimer {

    fileprivate weak var timer: Timer?
    fileprivate weak var target: AnyObject?
    fileprivate let action: (Timer) -> Void

    fileprivate init(timeInterval: TimeInterval,
                     target: AnyObject,
                     repeats: Bool,
                     action: @escaping (Timer) -> Void) {
        self.target = target
        self.action = action
        self.timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                          target: self,
                                          selector: #selector(fire),
                                          userInfo: nil,
                                          repeats: repeats)
    }

    class func scheduledTimer(timeInterval: TimeInterval,
                              target: AnyObject,
                              repeats: Bool,
                              action: @escaping (Timer) -> Void) -> Timer {
        return WeakTimer(timeInterval: timeInterval,
                         target: target,
                         repeats: repeats,
                         action: action).timer!
    }

    @objc fileprivate func fire(timer: Timer) {
        if target != nil {
            action(timer)
        } else {
            timer.invalidate()
        }
    }
}
