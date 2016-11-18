//
//  UIColorExtension.swift
//  PromotedBySwift
//
//  Created by bluedaquiri on 16/9/9.
//  Copyright © 2016年 blue. All rights reserved.
//

import UIKit

extension UIColor {
    /**< hex -> RGB */
    class func hexChangeFloat(hexColor: NSString) -> UIColor? {
        if hexColor.length < 6 {
            return nil
        }
        var red_   = UInt32()
        var green_ = UInt32()
        var blue_  = UInt32()
        var exceptionRange = NSRange()
        exceptionRange.length = 2
        // red
        exceptionRange.location = 0
        NSScanner(string: hexColor.substringWithRange(exceptionRange)).scanHexInt(&red_)
        // green
        exceptionRange.location = 2
        NSScanner(string: hexColor.substringWithRange(exceptionRange)).scanHexInt(&green_)
        // blue
        exceptionRange.location = 4
        NSScanner(string: hexColor.substringWithRange(exceptionRange)).scanHexInt(&blue_)
        
        let resultColor = UIColor(colorLiteralRed: Float(red_) / 255, green: Float(green_) / 255, blue: Float(blue_) / 255, alpha: 1)
        return resultColor
    }
    
    /**< customName -> proThemeColor */
    class func colorWithCustomName(colorName: String) -> UIColor? {
        var customColor : UIColor?
        switch colorName {
        case "分割线":
            customColor = UIColor.hexChangeFloat("e8e8e8")
        case "绿":
            customColor = UIColor.hexChangeFloat("5ac6aa")
        default:
            break
        }
        return customColor
    }
}