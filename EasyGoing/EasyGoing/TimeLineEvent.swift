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
