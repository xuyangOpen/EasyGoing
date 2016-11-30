//
//  RightArrowView.swift
//  EasyGoing
//
//  Created by King on 16/11/26.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

class RightArrowView: UIView {

    override func drawRect(rect: CGRect) {
        UIColor.whiteColor().set()
        UIRectFill(self.bounds)
        let context = UIGraphicsGetCurrentContext()
        
        //画三角形
        let startX = self.frame.size.width
        let startY = self.frame.size.height / 2.0
        //单位为总宽度的20%
        let unit = self.frame.width * 0.2
        CGContextMoveToPoint(context, startX, startY)
        CGContextAddLineToPoint(context, startX - unit, 0)
        CGContextAddLineToPoint(context, startX - unit, self.frame.size.height)
        CGContextClosePath(context)
        
        //画矩形
        let rectUnit = self.frame.height * 0.25
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, CGRectMake(0, rectUnit, rect.width*0.8, rect.height*0.5))
        CGContextAddPath(context, path)
        
        
        UIColor.blackColor().setFill()
        UIColor.blackColor().setStroke()
        
        CGContextDrawPath(context, .FillStroke)
    }
    
    
    
//    [[UIColor clearColor] set];
//    UIRectFill(self.bounds);
//    CGContextRef context=UIGraphicsGetCurrentContext();
//    
//    CGFloat startX = self.frame.size.width / 2.0;
//    CGFloat startY = 0;
//    CGContextMoveToPoint(context, startX, startY);//设置起点
//    CGContextAddLineToPoint(context, startX + 5, startY +5);
//    CGContextAddLineToPoint(context, startX -5, startY+5);
//    
//    CGContextClosePath(context);
//    [[UIColor whiteColor] setFill];
//    [[UIColor whiteColor] setStroke];
//    
//    CGContextDrawPath(context, kCGPathFillStroke);
}
