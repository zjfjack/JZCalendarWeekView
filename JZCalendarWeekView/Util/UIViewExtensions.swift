//
//  UIViewExtensions.swift
//  JZCalendarWeekView
//
//  Created by Jeff Zhang on 29/3/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import Foundation

extension UIView {
    
    //MARK: - Anchor Constranits
    func setAnchorConstraintsEqualTo(widthAnchor: CGFloat?=nil, heightAnchor: CGFloat?=nil, centerXAnchor: NSLayoutXAxisAnchor?=nil, centerYAnchor: NSLayoutYAxisAnchor?=nil) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let width = widthAnchor{
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = heightAnchor{
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
        if let centerX = centerXAnchor{
            self.centerXAnchor.constraint(equalTo: centerX).isActive = true
        }
        
        if let centerY = centerYAnchor{
            self.centerYAnchor.constraint(equalTo: centerY).isActive = true
        }
    }
    
    //bottomAnchor & trailingAnchor should be negative
    func setAnchorConstraintsEqualTo(widthAnchor: CGFloat?=nil, heightAnchor: CGFloat?=nil, topAnchor: (NSLayoutYAxisAnchor,CGFloat)?=nil, bottomAnchor: (NSLayoutYAxisAnchor,CGFloat)?=nil, leadingAnchor: (NSLayoutXAxisAnchor,CGFloat)?=nil, trailingAnchor: (NSLayoutXAxisAnchor,CGFloat)?=nil) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let width = widthAnchor{
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = heightAnchor{
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
        if let topY = topAnchor{
            self.topAnchor.constraint(equalTo: topY.0, constant: topY.1).isActive = true
        }
        
        if let botY = bottomAnchor{
            self.bottomAnchor.constraint(equalTo: botY.0, constant: botY.1).isActive = true
        }
        
        if let leadingX = leadingAnchor{
            self.leadingAnchor.constraint(equalTo: leadingX.0, constant: leadingX.1).isActive = true
        }
        
        if let trailingX = trailingAnchor{
            self.trailingAnchor.constraint(equalTo: trailingX.0, constant: trailingX.1).isActive = true
        }
    }
    
    func setAnchorCenterVerticallyTo(view: UIView, widthAnchor: CGFloat?=nil, heightAnchor: CGFloat?=nil, leadingAnchor: (NSLayoutXAxisAnchor,CGFloat)?=nil, trailingAnchor: (NSLayoutXAxisAnchor,CGFloat)?=nil) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        setAnchorConstraintsEqualTo(widthAnchor: widthAnchor, heightAnchor: heightAnchor, centerYAnchor: view.centerYAnchor)
        
        if let leadingX = leadingAnchor{
            self.leadingAnchor.constraint(equalTo: leadingX.0, constant: leadingX.1).isActive = true
        }
        
        if let trailingX = trailingAnchor{
            self.trailingAnchor.constraint(equalTo: trailingX.0, constant: trailingX.1).isActive = true
        }
    }
    
    func setAnchorCenterHorizontallyTo(view: UIView, widthAnchor: CGFloat?=nil, heightAnchor: CGFloat?=nil, topAnchor: (NSLayoutYAxisAnchor,CGFloat)?=nil, bottomAnchor: (NSLayoutYAxisAnchor,CGFloat)?=nil) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        setAnchorConstraintsEqualTo(widthAnchor: widthAnchor, heightAnchor: heightAnchor, centerXAnchor: view.centerXAnchor)
        
        if let topY = topAnchor{
            self.topAnchor.constraint(equalTo: topY.0, constant: topY.1).isActive = true
        }
        
        if let botY = bottomAnchor{
            self.bottomAnchor.constraint(equalTo: botY.0, constant: botY.1).isActive = true
        }
    }
    
    func setAnchorConstraintsFullSizeTo(view: UIView, padding: CGFloat = 0) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: view.topAnchor, constant: padding).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding).isActive = true
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding).isActive = true
    }
    //MARK: - General functions
    
    public func addSubviews(_ views: [UIView]) {
        views.forEach({ self.addSubview($0)})
    }
    
}
