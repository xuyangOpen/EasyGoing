//
//  CAGradientViewController.m
//  Animations
//
//  Created by YouXianMing on 16/2/16.
//  Copyright © 2016年 YouXianMing. All rights reserved.
//

#import "CAGradientViewController.h"
#import "CAGradientMaskView.h"
#import "GCD.h"

#define _md_get_weakSelf() __weak typeof(self) weakSelf = self

typedef enum : NSUInteger {
    
    kTypeOne,
    kTypeTwo,
    
} EType;

@interface CAGradientViewController ()

@property (nonatomic, strong) NSArray   *images;
@property (nonatomic)         NSInteger  count;

@property (nonatomic, strong) CAGradientMaskView *tranformFadeViewOne;
@property (nonatomic, strong) CAGradientMaskView *tranformFadeViewTwo;

@property (nonatomic, strong) GCDTimer *timer;
@property (nonatomic)         EType     type;

@end

@implementation CAGradientViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
 //   [self addGradientOnView:self.view];
}

- (void)addGradientOnView:(UIView *)contentView andImages:(NSArray<UIImage *> *)images{
    self.view.backgroundColor = [UIColor blueColor];
    self.images = images ;
    
    self.tranformFadeViewOne               = [[CAGradientMaskView alloc] initWithFrame:contentView.bounds];
    self.tranformFadeViewOne.contentMode   = UIViewContentModeScaleAspectFill;
    self.tranformFadeViewOne.fadeDuradtion = 4.f;
    
    self.tranformFadeViewOne.image         = [self currentImage];
    
    [contentView addSubview:self.tranformFadeViewOne];
    
    self.tranformFadeViewTwo               = [[CAGradientMaskView alloc] initWithFrame:contentView.bounds];
    self.tranformFadeViewTwo.contentMode   = UIViewContentModeScaleAspectFill;
    self.tranformFadeViewTwo.fadeDuradtion = 4.f;
    [contentView addSubview:self.tranformFadeViewTwo];
    [self.tranformFadeViewTwo fadeAnimated:NO];
    
    // timer
    _md_get_weakSelf();
    self.timer = [[GCDTimer alloc] initInQueue:[GCDQueue mainQueue]];
    [self.timer event:^{
        
        [weakSelf timerEvent:contentView];
        
    } timeIntervalWithSecs:6 delaySecs:1.f];
    [self.timer start];
}

- (void)timerEvent:(UIView *)contentView {

    if (self.type == kTypeOne) {
        
        self.type = kTypeTwo;
        
        [contentView sendSubviewToBack:self.tranformFadeViewTwo];
        self.tranformFadeViewTwo.image = [self currentImage];
        [self.tranformFadeViewTwo showAnimated:NO];
        [self.tranformFadeViewOne fadeAnimated:YES];
        
    } else {
        
        self.type = kTypeOne;
        
        [contentView sendSubviewToBack:self.tranformFadeViewOne];
        self.tranformFadeViewOne.image = [self currentImage];
        [self.tranformFadeViewOne showAnimated:NO];
        [self.tranformFadeViewTwo fadeAnimated:YES];
    }
}

- (UIImage *)currentImage {
    
    self.count = ++self.count % self.images.count;
    
    return self.images[self.count];
}

@end
