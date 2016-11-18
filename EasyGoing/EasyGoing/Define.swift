//
//  Define.swift
//  EasyGoing
//
//  Created by King on 16/9/21.
//  Copyright © 2016年 kf. All rights reserved.
//

import Foundation
import AFNetworking

    //网络监测
    let networkReachabilityManager = AFNetworkReachabilityManager.sharedManager()

    //定义表名
    /**
        我的小金库
    */
    let TimeLine_record = "TimeLineRecord"


    //MARK:表名的定义
    //用户设置表（保存了用户登录的口令，设置信息）
    let EGUser = "eg_user"
