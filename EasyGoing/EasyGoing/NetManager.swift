//
//  NetManager.swift
//  EasyGoing
//
//  Created by King on 16/9/21.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

typealias networkReachabilityClosure = (Bool,String) -> Void

class NetManager: NSObject {
    
    //判断网络是否可用  返回值1表示是否可用，返回值2表示错误提示
    class func isNetAvailable(detectionComplete:networkReachabilityClosure) -> Void{
        networkReachabilityManager.setReachabilityStatusChangeBlock { (netStatus) in
            switch netStatus{
            case .Unknown:
                detectionComplete(false,NSLocalizedString("Unknown network", comment: "未知网络"))
            case .NotReachable:
                detectionComplete(false,NSLocalizedString("Not Available Network", comment: "网络不可用，请检查网络连接"))
            case .ReachableViaWWAN:
                detectionComplete(true,"")
            case .ReachableViaWiFi:
                detectionComplete(true,"")
            }
        }
    }
}
