//
//  WaterFlowModel.swift
//  EasyGoing
//
//  Created by King on 16/9/21.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

public enum UICollectionStyle : Int {
    
    case None = 0                              //无动画
    case CAGradientLayer                       // CAGradientLayer动画
    case Easing                                // Easing 圆形动画
    case Clock                                 //时间显示
    case EmitterSnow                           //粒子雪花
    case MusicBar                              //音乐节奏条
    case WaterWave                             //水波纹
}

class WaterFlowModel: NSObject {

    //item的高度
    var itemHeight:CGFloat = 0.0
    //item的颜色
    var itemColor:UIColor?
    //item的动画类型
    var style:UICollectionStyle?
    //item的高度
    var itemWidth:CGFloat = 0.0
}
