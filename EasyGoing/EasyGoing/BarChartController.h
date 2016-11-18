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
//数据源
@property (nonatomic, strong)NSDictionary<NSString *,NSNumber *> *categoryDictionary;
@property (nonatomic, strong)NSDictionary<NSString *,NSNumber *> *costDictionary;

//更新视图
- (void)loadBarChartView;
//初始化视图
-(void)updateData;

@end
