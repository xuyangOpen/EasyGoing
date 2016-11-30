//
//  BarChartController.h
//  EasyGoing
//
//  Created by King on 16/11/17.
//  Copyright © 2016年 kf. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BarChartDelegate <NSObject>

@optional
- (void)showMonthAtIndex:(NSNumber *) index;

@end

@interface BarChartController : UIViewController

//动画
@property (nonatomic, assign)BOOL animation;
//代理方法
@property (nonatomic, weak)id<BarChartDelegate> delegate;

//数据源
@property (nonatomic, strong)NSDictionary<NSNumber *,NSNumber *> *costDictionary;
//Y轴最大值
@property (nonatomic, assign)CGFloat maxY;

//更新视图
- (void)loadBarChartView;
//初始化视图
-(void)updateData;

//更新视图大小
- (void)changeFrameSize:(CGRect)size animationDuration:(CGFloat) time;

@end
