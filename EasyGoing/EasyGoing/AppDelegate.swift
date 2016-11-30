//
//  AppDelegate.swift
//  EasyGoing
//
//  Created by King on 16/8/29.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit
import AVOSCloud
import AudioToolbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,BMKGeneralDelegate{

    var window: UIWindow?
    
    var _mapManager: BMKMapManager?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //初始化LeanCloud数据存储服务
        AVOSCloud.setApplicationId("Ib3GGpkADGmJzJO6hp0xTb6F-gzGzoHsz", clientKey: "k7rHYRTrnMG0AO07EO97qYzI")
        
        //判断是否登录
//        AVUser.logOut()
        let user = AVUser.currentUser()
        if user == nil {//没有登录的情况下，跳转到登录界面
            let loginNav = UINavigationController.init(rootViewController: LoginViewController())
            loginNav.navigationBar.tintColor = Utils.allTintColor
            self.window?.rootViewController = loginNav
        }else{//已经登录的情况下，直接跳转到主界面
            let homeNav = UINavigationController.init(rootViewController: HomeViewController())
            homeNav.navigationBar.tintColor = Utils.allTintColor
            self.window?.rootViewController = homeNav
        }
        
        //百度地图初始化
        _mapManager = BMKMapManager()
        // 如果要关注网络及授权验证事件，请设定generalDelegate参数
        let ret = _mapManager?.start("Dw4swcCWsVRb3Q7MjrkxP2bihVUUzpPT", generalDelegate: self)
        if ret == false {
            NSLog("百度地图初始化失败")
        }
        
        return true
    }
    
    //MARK:收到通知时
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        //将Badge清除
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        //获取userInfo
        let userInfo = notification.userInfo
        
        if userInfo != nil && userInfo!["Arrived"] != nil {
            //开启震动
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            //弹窗提示
            let alert = UIAlertController.init(title: "提示", message: userInfo!["Arrived"] as? String, preferredStyle: .Alert)
            let action = UIAlertAction.init(title: "好", style: .Destructive) { (action) in
                //关闭提示音乐
                SystemMusic.shareInstance.stopMusic()
            }
            alert.addAction(action)
            let delegate = UIApplication.sharedApplication().delegate
            let nav = delegate?.window!!.rootViewController as! UINavigationController
            
            nav.viewControllers[0].presentViewController(alert, animated: true, completion: nil)
            
            //注销推送
            self.cancelLocalNotication("Arrived")
        }
    }

    //MARK:注销本次推送
    func cancelLocalNotication(key: String){
        let localNotifications = UIApplication.sharedApplication().scheduledLocalNotifications
        for noti in localNotifications! {
            let userInfo = noti.userInfo
            if userInfo != nil && userInfo![key] != nil {
                UIApplication.sharedApplication().cancelLocalNotification(noti)
                break
            }
        }
    }
    
    
    //MARK:程序即将要进入后台时
    func applicationWillResignActive(application: UIApplication) {
        
    }

    //MARK:程序已经进入后台
    func applicationDidEnterBackground(application: UIApplication) {

    }

    //MARK:程序即将进入前台运行时
    func applicationWillEnterForeground(application: UIApplication) {
        //如果正在加载设置界面，则视图动画继续运行
        if Utils.sharedInstance.glassHour != nil && Utils.sharedInstance.glassHourParentView != nil{
            Utils.sharedInstance.showHourGlassOnView(Utils.sharedInstance.glassHourParentView!)
        }
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }

    //MARK:程序已经进入前台运行时
    func applicationDidBecomeActive(application: UIApplication) {
        
    }

    //MARK:程序即将终止时
    func applicationWillTerminate(application: UIApplication) {
        
    }


}

