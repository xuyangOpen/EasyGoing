//
//  CircleAnimationViewController.m
//  Animations
//
//  Created by YouXianMing on 15/11/24.
//  Copyright © 2015年 YouXianMing. All rights reserved.
//

#import "CircleAnimationViewController.h"
#import "CircleView.h"
#import "GCD.h"
#import "UIView+SetRect.h"

#define _md_get_weakSelf() __weak typeof(self) weakSelf = self

@interface CircleAnimationViewController ()

@property (nonatomic, strong) CircleView  *circleView4;

@property (nonatomic, strong) GCDTimer    *timer;

@end

@implementation CircleAnimationViewController

- (void)addEasingOnView:(UIView *)contentView {
    
    CGFloat gapFromTop = 64.f + 20;
    CGFloat width      = contentView.width;
    
    CGFloat halfWidth  = width / 2.f;
    CGFloat radius     = width / 3.f + 20;
    
    CGPoint point4     = CGPointMake(halfWidth / 2.f + halfWidth, gapFromTop + halfWidth / 2.f + halfWidth);
    
    // Circle
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, radius, radius)];
    imageView.image        = [UIImage imageNamed:@"colors"];
    imageView.center       = point4;
    [contentView addSubview:imageView];
    imageView.center = contentView.center;
    self.circleView4 = [CircleView circleViewWithFrame:CGRectMake(0, 0, radius, radius) lineWidth:radius / 2.f lineColor:[UIColor blackColor]
                                             clockWise:YES startAngle:0];
    imageView.layer.mask = self.circleView4.layer;
    
    _md_get_weakSelf();
    self.timer = [[GCDTimer alloc] initInQueue:[GCDQueue mainQueue]];
    [self.timer event:^{
        
        CGFloat percent        = arc4random() % 100 / 100.f;
        CGFloat anotherPercent = arc4random() % 100 / 100.f;
        CGFloat largePercent   = (percent < anotherPercent ? anotherPercent : percent);
        [weakSelf.circleView4 strokeEnd:largePercent   animationType:ExponentialEaseOut animated:YES duration:1.f];
        
    } timeIntervalWithSecs:1.5f];
    
    [self.timer start];
}

@end
