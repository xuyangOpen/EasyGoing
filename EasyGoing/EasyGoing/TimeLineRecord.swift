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
    var childId = ""
    var parentId = ""
    var parentName = ""
    
    //数据库对应字段
    var userId = ""                         //用户id
    var recordTime = ""                     //消费时间
    var recordEvent = ""                    //消费项目
    var recordCost:CGFloat = 0.0            //消费金额
    var recordMark = ""                     //备注
    
    
    //将AVObject类转换成TimeLineRecord类
    class func initRecordWithAVObject(avObject:AVObject) -> TimeLineRecord{
        let model = TimeLineRecord()
        let childEvent = avObject.objectForKey("eventObject") as! AVObject
        let child = childEvent.objectForKey("eventName") as! String
        //获取当前分类的objectId
        model.childId = childEvent.objectForKey("objectId") as! String
        
        //父目录
        let parentEvent = childEvent.objectForKey("parentId") as! AVObject
        model.parentName = parentEvent.objectForKey("eventName") as! String
        
        //获取当前分类的父目录objectId
        model.parentId = parentEvent.objectForKey("objectId") as! String
        model.recordEvent = model.parentName + " - " + child
        model.recordCost = CGFloat(avObject.objectForKey("recordCost").floatValue)
        model.recordTime = avObject.objectForKey("recordTime") as! String
        model.recordMark = avObject.objectForKey("recordMark") as! String
        
        return model
    }
}
