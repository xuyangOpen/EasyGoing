//
//  MusicBarAnimationController.m
//  Animations
//
//  Created by YouXianMing on 16/1/15.
//  Copyright © 2016年 YouXianMing. All rights reserved.
//

#import "MusicBarAnimationController.h"
#import "UIFont+Fonts.h"
#import "UIView+SetRect.h"
#import "GCD.h"

@interface MusicBarAnimationController ()

@property (nonatomic, strong) GCDTimer  *timer;

@end

@implementation MusicBarAnimationController

- (void)addMusicBarOnView:(UIView *)contentView {
    
    contentView.backgroundColor = [UIColor blackColor];
    
    CGFloat width  = contentView.frame.size.width;
    CGFloat height = contentView.frame.size.height;
    
    CAReplicatorLayer *replicatorLayer = [CAReplicatorLayer layer];
    [contentView.layer addSublayer:replicatorLayer];
    
    replicatorLayer.frame              = CGRectMake(0, 0, width, height);
    //这里改变了音乐条的起始高度
    CGPoint center = contentView.center;
    center.y -= 22;
    replicatorLayer.position           = center;
    
    replicatorLayer.instanceCount      = width / 8;
    replicatorLayer.masksToBounds      = YES;
    replicatorLayer.instanceTransform  = CATransform3DMakeTranslation(-8.0, 0.0, 0.0);
    replicatorLayer.instanceDelay      = 0.5f;
    
    CALayer *layer        = [CALayer layer];
    layer.frame           = CGRectMake(width - 4, height, 4, height);
    layer.backgroundColor = [UIColor blackColor].CGColor;
    layer.cornerRadius    = 2.f;
    [replicatorLayer addSublayer:layer];
    
    self.timer = [[GCDTimer alloc] initInQueue:[GCDQueue mainQueue]];
    [self.timer event:^{
        
        CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
        colorAnimation.toValue           = (id)[UIColor colorWithRed:arc4random() % 256 / 255.f
                                                               green:arc4random() % 256 / 255.f
                                                                blue:arc4random() % 256 / 255.f
                                                               alpha:1].CGColor;
        
        CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
        positionAnimation.toValue           = @(layer.position.y - arc4random() % ((NSInteger)height - 64));
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.duration          = 1.f;
        group.autoreverses      = true;
        group.repeatCount       = 20;
        group.timingFunction    = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        group.animations        = @[colorAnimation, positionAnimation];
        [layer addAnimation:group forKey:nil];
        
    } timeIntervalWithSecs:1.f delaySecs:1.f];
    [self.timer start];
}

@end
