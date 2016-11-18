//
//  BackView.m
//  EasyGoing
//
//  Created by King on 16/11/15.
//  Copyright © 2016年 kf. All rights reserved.
//

#import "BackView.h"

@implementation BackView

- (void)drawRect:(CGRect)rect{
    
    
    [[UIColor clearColor] set];
    UIRectFill(self.bounds);
    CGContextRef context=UIGraphicsGetCurrentContext();
    
    CGFloat startX = self.frame.size.width / 2.0;
    CGFloat startY = 0;
    CGContextMoveToPoint(context, startX, startY);//设置起点
    CGContextAddLineToPoint(context, startX + 5, startY +5);
    CGContextAddLineToPoint(context, startX -5, startY+5);
    
    CGContextClosePath(context);
    [[UIColor whiteColor] setFill];
    [[UIColor whiteColor] setStroke];
    
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end
