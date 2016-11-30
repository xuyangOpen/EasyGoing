//
//  ObjectC-Bridging-Header.h
//  EasyGoing
//
//  Created by King on 16/8/29.
//  Copyright © 2016年 kf. All rights reserved.
//

#ifndef ObjectC_Bridging_Header_h
#define ObjectC_Bridging_Header_h

#import <AVOSCloud/AVOSCloud.h>     //数据存储

#import "HcdPopMenu.h"              //弹出层菜单
#import "WBPopOverView.h"           //TimeLine右上角+号弹出层

#import "SZCalendarPicker.h"

//动画VC
#import "CAGradientViewController.h"
#import "CircleAnimationViewController.h"
#import "EmitterSnowController.h"
#import "MusicBarAnimationController.h"
#import "WaterWaveViewController.h"

#import "FeHourGlass.h"

#import "RandomString.h"        //生成随机的uuid字符串

#import "PieChartViewController.h"  //饼状图
#import "BarChartController.h"      //柱形图
@import Charts;                     //导入Charts module ，供OC使用
@import Masonry;


#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件
#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>//引入云检索功能所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件
//#import <BaiduMapAPI_Radar/BMKRadarComponent.h>//引入周边雷达功能所有的头文件
#import <BaiduMapAPI_Map/BMKMapView.h>//只引入所需的单个头文件

#import "RouteAnnotation.h"//百度地图路线规划使用类
#import "UIImage+Rotate.h"


#endif /* ObjectC_Bridging_Header_h */
