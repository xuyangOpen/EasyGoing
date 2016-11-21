//
//  BarChartController.h
//  EasyGoing
//
//  Created by King on 16/11/17.
//  Copyright © 2016年 kf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BarChartController : UIViewController

//视图位置
@property (nonatomic, assign)CGRect showFrame;
//动画
@property (nonatomic, assign)BOOL animation;
//数据源
@property (nonatomic, strong)NSDictionary<NSNumber *,NSNumber *> *costDictionary;
//Y轴最大值
@property (nonatomic, assign)CGFloat maxY;

//更新视图
- (void)loadBarChartView;
//初始化视图
-(void)updateData;

@end
