//
//  ToastUtil.swift
//  JZiOSFramework
//
//  Created by Jeff Zhang on 22/3/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit

open class ToastUtil {
    
    public enum ToastPosition {
        case top, bottom, middle
    }
    
    static private let defaultLabelSidesPadding: CGFloat = 20
    
    static private let defaultMidFont = UIFont.systemFont(ofSize: 13)
    static private let defaultMidBgColor = UIColor(hex: 0xE8E8E8)
    static private let defaultMidTextColor = UIColor.darkGray
    static private let defaultMidHeight: CGFloat = 40
    static private let defaultMidMinWidth: CGFloat = 80
    static private let defaultMidToBottom: CGFloat = 20 + UITabBarController().tabBar.frame.height
    
    static private let defaultTopBotFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
    static private let defaultTopBotTextColor = UIColor.white
    static private let defaultTopBotBgColor = UIColor.darkGray
    static private let defaultTopBotHeight = UIApplication.shared.statusBarFrame.height + UINavigationController().navigationBar.frame.height
    
    static private let defaultExistTime: TimeInterval = 2.0
    static private let defaultShowTime: TimeInterval = 0.5
    
    static private var toastView: UIView!
    
    public static func toastMessageInTheMiddle(message: String, bgColor: UIColor? = nil, existTime: TimeInterval? = nil) {
        
        guard let currentWindow = (UIApplication.shared.delegate as? AppDelegate)?.window, toastView == nil else { return }
        
        toastView = UIView()
        toastView.backgroundColor = defaultMidBgColor
        toastView.alpha = 0
        toastView.layer.cornerRadius = defaultMidHeight/2
        toastView.clipsToBounds = true
        let toastLabel =  addToastLabel(message: message, toastPosition: .middle)
        
        currentWindow.addSubview(toastView)
        var bottomYAnchor: NSLayoutYAxisAnchor
        // Support iPhone X
        if #available(iOS 11.0, *) {
            bottomYAnchor = currentWindow.safeAreaLayoutGuide.bottomAnchor
        } else {
            bottomYAnchor = currentWindow.bottomAnchor
        }
        
        toastView.setAnchorCenterHorizontallyTo(view: currentWindow, heightAnchor: defaultMidHeight, bottomAnchor: (bottomYAnchor, -defaultMidToBottom))
        toastView.widthAnchor.constraint(greaterThanOrEqualToConstant: defaultMidMinWidth).isActive = true
        
        let delay = existTime ?? defaultExistTime
        UIView.animate(withDuration: defaultShowTime, delay: 0, options: .curveEaseInOut, animations: {
            toastView.alpha = 1
            toastLabel.alpha = 1
        }, completion: { _ in
            
            UIView.animate(withDuration: defaultShowTime, delay: delay, options: .curveEaseInOut, animations: {
                toastView.alpha = 0
                toastLabel.alpha = 0
            }, completion: { _ in
                toastView.removeFromSuperview()
                toastView = nil
            })
        })
    }
    
    public static func toastMessageFromTopOrBottom(message: String, toastPosition: ToastPosition = .top, bgColor: UIColor? = nil,
                                                   existTime: TimeInterval? = nil, hideStatusBar: Bool = true) {
        
        guard let currentWindow = (UIApplication.shared.delegate as? AppDelegate)?.window, toastView == nil else { return }
        let isFromTop = toastPosition == .top
        
        toastView = UIView()
        toastView.backgroundColor = bgColor ?? defaultTopBotBgColor
        let toastLabel = addToastLabel(message: message, toastPosition: toastPosition)
        currentWindow.addSubview(toastView)
        
        let topAnchorTuple = isFromTop ? (currentWindow.topAnchor, -defaultTopBotHeight) : (currentWindow.bottomAnchor, 0)
        toastView.setAnchorConstraintsEqualTo(heightAnchor: defaultTopBotHeight, topAnchor: topAnchorTuple, leadingAnchor: (currentWindow.leadingAnchor, 0), trailingAnchor: (currentWindow.trailingAnchor, 0))
        
        toastViewAddSwipeBackGesture(isFromTop: toastPosition == .top, currentWindow: currentWindow)
        
        let delay = existTime ?? defaultExistTime
        let shouldHideStatusBar = hideStatusBar && isFromTop
        if shouldHideStatusBar { currentWindow.windowLevel = UIWindowLevelStatusBar }
        
        UIView.animate(withDuration: defaultShowTime, delay: 0, options: .curveEaseInOut, animations: {
            toastView.transform = CGAffineTransform(translationX: 0, y: isFromTop ? defaultTopBotHeight : -defaultTopBotHeight)
            toastLabel.alpha = 1
        }, completion: { _ in
            
            UIView.animate(withDuration: defaultShowTime, delay: delay, options: .curveEaseInOut, animations: {
                toastView.transform = CGAffineTransform.identity
                toastLabel.alpha = 0
            }, completion: { _ in
                if shouldHideStatusBar { currentWindow.windowLevel = UIWindowLevelNormal }
                toastView?.removeFromSuperview()
                toastView = nil
            })
        })
    }
    
    private static func toastViewAddSwipeBackGesture(isFromTop: Bool, currentWindow: UIWindow) {
        let gestureIndicator = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        let indicatorSize = CGSize(width: 40, height: 4)
        let indicatorToEdge: CGFloat = 5
        gestureIndicator.alpha = 0.8
        gestureIndicator.layer.cornerRadius = indicatorSize.height/2
        gestureIndicator.clipsToBounds = true
        toastView.addSubview(gestureIndicator)
        if isFromTop {
            gestureIndicator.setAnchorCenterHorizontallyTo(view: toastView, widthAnchor: indicatorSize.width, heightAnchor: indicatorSize.height, bottomAnchor: (toastView.bottomAnchor, -indicatorToEdge))
        } else {
            gestureIndicator.setAnchorCenterHorizontallyTo(view: toastView, widthAnchor: indicatorSize.width, heightAnchor: indicatorSize.height, topAnchor: (toastView.topAnchor, indicatorToEdge))
        }
        
        let gestureView = UIView()
        currentWindow.addSubview(gestureView)
        let topAnchorTuple = isFromTop ? (currentWindow.topAnchor, 0) : (currentWindow.bottomAnchor, defaultTopBotHeight)
        gestureView.setAnchorConstraintsEqualTo(heightAnchor: defaultTopBotHeight, topAnchor: topAnchorTuple, leadingAnchor: (currentWindow.leadingAnchor, 0), trailingAnchor: (currentWindow.trailingAnchor, 0))
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(gestureViewSwiped(_:)))
        gestureView.addGestureRecognizer(tapGesture)
        gestureView.isUserInteractionEnabled = true
    }
    
    @objc private static func gestureViewSwiped(_ recognizer: UIGestureRecognizer) {
        toastView.layer.removeAllAnimations()
//        UIView.animate(withDuration: 0.2) {
//            toastView.transform = CGAffineTransform.identity
//        }
    }
    
    private static func addToastLabel(message: String, toastPosition: ToastPosition) -> UILabel {
        let isMiddle = toastPosition == .middle
        let font = isMiddle ? defaultMidFont : defaultTopBotFont
        let textColor = isMiddle ? defaultMidTextColor : defaultTopBotTextColor
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.font = font
        toastLabel.textColor = textColor
        toastLabel.textAlignment = .center
        toastLabel.alpha = 0
        toastView.addSubview(toastLabel)
        let centerYConstant: CGFloat = {
            if isMiddle {
                return 0
            } else {
                // Support iPhone X
                let statusBarHeight = UIApplication.shared.statusBarFrame.height
                let hasNotch: Bool = statusBarHeight > 20
                let shouldAdjustYOffset = hasNotch && UIApplication.shared.statusBarOrientation.isPortrait && toastPosition == .top
                if shouldAdjustYOffset {
                    return statusBarHeight/2 - 15
                }
                return 0
            }
        }()
        toastLabel.centerYAnchor.constraint(equalTo: toastView.centerYAnchor, constant: centerYConstant).isActive = true
        toastLabel.setAnchorConstraintsEqualTo(heightAnchor: defaultMidHeight, leadingAnchor: (toastView.leadingAnchor, defaultLabelSidesPadding), trailingAnchor: (toastView.trailingAnchor, -defaultLabelSidesPadding))
        
        return toastLabel
    }
}
