//
//  PieChartViewController.h
//  EasyGoing
//
//  Created by King on 16/11/17.
//  Copyright © 2016年 kf. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PieChartDelegate <NSObject>

@optional
- (void)showEventAtIndex:(NSNumber *) index;

@end

@interface PieChartViewController : UIViewController

//视图中间的日期
@property (nonatomic) NSString *centerDateString;
//动画
@property (nonatomic, assign)BOOL animation;
//代理
@property (nonatomic, weak) id<PieChartDelegate> delegate;

//数据源
@property (nonatomic, strong)NSDictionary<NSString *,NSNumber *> *categoryDictionary;
@property (nonatomic, strong)NSDictionary<NSString *,NSNumber *> *costDictionary;

//初始化视图
- (void)loadPieChartView;

//更新视图
- (void)updateData;

//更新视图大小
- (void)changeFrameSize:(CGRect)size animationDuration:(CGFloat) time;

@end
