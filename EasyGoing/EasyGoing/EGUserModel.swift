//
//  EGUser.swift
//  EasyGoing
//
//  Created by King on 16/11/11.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit
import AVOSCloud

class EGUserModel: NSObject {

    var userOnlyKey = ""            //登录口令
    var userUUID = ""               //用户登录密码
    var isSet = ""                  //是否已经配置了用户数据  1表示已配置 2表示未配置
    
    class func initEGUserWithAVObject(avObject:AVObject) -> EGUserModel{
        let egUser = EGUserModel()
        egUser.userOnlyKey = avObject.objectForKey("userOnlyKey") as! String
        egUser.userUUID = avObject.objectForKey("userUUID") as! String
        egUser.isSet = avObject.objectForKey("isSet") as! String
        return egUser
    }
}
