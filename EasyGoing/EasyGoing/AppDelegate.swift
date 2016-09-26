//
//  AppDelegate.swift
//  EasyGoing
//
//  Created by King on 16/8/29.
//  Copyright © 2016年 kf. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //初始化LeanCloud数据存储服务
        AVOSCloud.setApplicationId("Ib3GGpkADGmJzJO6hp0xTb6F-gzGzoHsz", clientKey: "k7rHYRTrnMG0AO07EO97qYzI")
        
//        let home = HomeTabBarController()
//        
// //       let timeLine = UIStoryboard(name: "TimeLine",bundle: nil).instantiateViewControllerWithIdentifier("timeline")
//        
//        let nav1 = UINavigationController.init(rootViewController: TimeLineController())
//        
//        
//        
//        let nav2 = UINavigationController.init(rootViewController: ChartController())
//        let nav3 = UINavigationController.init(rootViewController: WhateverController())
//        let nav4 = UINavigationController.init(rootViewController: MeController())
//        home.viewControllers = [nav1,nav2,nav3,nav4]
        
        let homeNav = UINavigationController.init(rootViewController: HomeViewController())
        self.window?.rootViewController = homeNav
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

