//
//  AnnotationDownArrow.swift
//  EasyGoing
//
//  Created by King on 16/11/24.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

class AnnotationDownArrow: UIView {

    override func drawRect(rect: CGRect) {
        
        UIColor.clearColor().set()
        UIRectFill(self.bounds)
        
        let context = UIGraphicsGetCurrentContext()
        let startX = self.frame.size.width / 2.0
        let startY = self.frame.size.height
        CGContextMoveToPoint(context, startX, startY)//设置起点
        CGContextAddLineToPoint(context, startX + 5, startY - 5)
        CGContextAddLineToPoint(context, startX - 5, startY - 5)
        
        CGContextClosePath(context)
        UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7).setFill()
        UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7).setStroke()
        CGContextDrawPath(context, .FillStroke)
    }
}
