//
//  TimeLineRecord.swift
//  EasyGoing
//
//  Created by King on 16/9/23.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit
import AVOSCloud

typealias recordDeleteClosure = (NSError?) -> Void

class TimeLineRecord: NSObject {

    //非数据库对应字段
    var isExpand = false                    //是否展开的属性
    var childId = ""
    var parentId = ""
    var parentName = ""
    
    //数据库对应字段
    var objectId = ""                       //主键id
    var userId = ""                         //用户id
    var recordTime = ""                     //消费时间
    var recordEvent = ""                    //消费项目
    var recordCost:CGFloat = 0.0            //消费金额
    var recordMark = ""                     //备注
    
    var createdAt = ""                      //创建时间
    
    //将AVObject类转换成TimeLineRecord类
    class func initRecordWithAVObject(avObject:AVObject) -> TimeLineRecord{
        let model = TimeLineRecord()
        model.objectId = avObject.objectForKey("objectId") as! String
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
        model.recordCost = avObject.objectForKey("recordCost") as! CGFloat
        model.recordTime = avObject.objectForKey("recordTime") as! String
        model.recordMark = avObject.objectForKey("recordMark") as! String
        
        //创建时间
        let createdDate = avObject.objectForKey("createdAt") as! NSDate
        model.createdAt = String(createdDate.timeIntervalSince1970 * 1000)
        
        return model
    }
    
    //MARK:删除
    class func deleteModel(model: TimeLineRecord, complete: recordDeleteClosure){
        
        AVQuery.doCloudQueryInBackgroundWithCQL("delete from TimeLineRecord where objectId='" + model.objectId + "' ") { (result, error) in
            if error == nil{
                complete(nil)
            }else{
                complete(error)
            }
        }
    }
    
}
