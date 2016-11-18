//
//  AppDelegate.swift
//  EasyGoing
//
//  Created by King on 16/8/29.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit
import AVOSCloud

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

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
        
        return true
    }

//    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
//        return AVOSCloudSNS.handleOpenURL(url)
//    }
//    
//    // When Build with IOS 9 SDK
//    // For application on system below ios 9
//    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
//        return AVOSCloudSNS.handleOpenURL(url)
//    }
//    
//    // For application on system equals or larger ios 9
//    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
//        return AVOSCloudSNS.handleOpenURL(url)
//    }
//    
    
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
    }

    //MARK:程序已经进入前台运行时
    func applicationDidBecomeActive(application: UIApplication) {
        
    }

    //MARK:程序即将终止时
    func applicationWillTerminate(application: UIApplication) {
        
    }


}

