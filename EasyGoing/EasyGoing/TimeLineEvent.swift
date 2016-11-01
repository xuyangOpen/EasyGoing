//
//  TimeLineEvent.swift
//  EasyGoing
//
//  Created by King on 16/9/27.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

class TimeLineEvent: NSObject {
    
    var objectId = ""                   //主键
    var parentId = ""                   //父目录主键
    var eventName = ""                  //项目名称
    var parentName = ""                 //父目录名称
    var userId = ""                     //用户id
    
    var updatedAt = ""                  //更新时间
    
    //通过AVObject初始化TimeLineEvent类
    class func initEventWithAVObject(avObject:AVObject) -> TimeLineEvent{
        let model = TimeLineEvent()
        model.eventName = avObject.objectForKey("eventName") as! String
        let date = avObject.objectForKey("updatedAt") as! NSDate
        model.updatedAt = String(date.timeIntervalSince1970 * 1000)
        model.objectId = avObject.objectForKey("objectId") as! String
        if avObject.objectForKey("userId") != nil{
            model.userId = avObject.objectForKey("userId") as! String
        }
        //查询父目录id
        if avObject.objectForKey("parentId") != nil{
            let parentObject = avObject.objectForKey("parentId") as! AVObject
            model.parentId = parentObject.objectForKey("objectId") as! String
        }
        return model
    }
    
    //将TimeLineEvent类转换成AVObject
    class func convertEventModelToAVObject(event:TimeLineEvent) -> AVObject{
        let avObject = AVObject.init(className: "TimeLineEvent")
        avObject.setObject(event.objectId, forKey: "objectId")
        avObject.setObject(event.eventName, forKey: "eventName")
        return avObject
    }
    
    /**
     let obj = AVObject.init(className: "TimeLineEvent")
     obj.setObject("投资", forKey: "eventName")
     obj.setObject("", forKey: "userId")
     obj.saveInBackgroundWithBlock { (result, error) in
     if error == nil{
     let obj4 = AVObject.init(className: "TimeLineEvent")
     obj4.setObject("股票", forKey: "eventName")
     obj4.setObject("", forKey: "userId")
     obj4.setObject("", forKey: "parentId")
     obj4.setObject(AVObject.init(className: "TimeLineEvent", objectId: obj.objectId), forKey: "parentId")
     obj4.saveInBackground()
     
     let obj1 = AVObject.init(className: "TimeLineEvent")
     obj1.setObject("国债", forKey: "eventName")
     obj1.setObject("", forKey: "userId")
     obj1.setObject("", forKey: "parentId")
     obj1.setObject(AVObject.init(className: "TimeLineEvent", objectId: obj.objectId), forKey: "parentId")
     obj1.saveInBackground()
     
     let obj2 = AVObject.init(className: "TimeLineEvent")
     obj2.setObject("彩票", forKey: "eventName")
     obj2.setObject("", forKey: "userId")
     obj2.setObject("", forKey: "parentId")
     obj2.setObject(AVObject.init(className: "TimeLineEvent", objectId: obj.objectId), forKey: "parentId")
     obj2.saveInBackground()
     
     let obj3 = AVObject.init(className: "TimeLineEvent")
     obj3.setObject("保险", forKey: "eventName")
     obj3.setObject("", forKey: "userId")
     obj3.setObject("", forKey: "parentId")
     obj3.setObject(AVObject.init(className: "TimeLineEvent", objectId: obj.objectId), forKey: "parentId")
     obj3.saveInBackground()
     }
     }
     */
    
}
