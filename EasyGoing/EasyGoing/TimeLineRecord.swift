//
//  TimeLineRecord.swift
//  EasyGoing
//
//  Created by King on 16/9/23.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

class TimeLineRecord: NSObject {

    //非数据库对应字段
    var isExpand = false                    //是否展开的属性
    //数据库对应字段
    var userId = ""                         //用户id
    var recordTime = ""                     //消费时间
    var recordEvent = ""                    //消费项目
    var recordCost:CGFloat = 0.0            //消费金额
    var recordMark = ""                     //备注
    
}
