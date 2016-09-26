//
//  Utils.swift
//  eiisys讲堂
//
//  Created by tanghy on 16/5/23.
//  Copyright © 2016年 tanghy. All rights reserved.
//

import UIKit
import MBProgressHUD

class Utils: NSObject{
    
    //单例模式的Utils工具类
    static let sharedInstance = Utils()
    private override init() {}
    
    
    let hud = MBProgressHUD.showHUDAddedTo(Utils.currentView, animated: true)
    func showLoadingView(msg:String){
        hud.mode = .Text
        hud.label.text = msg + "..."
        hud.mode = .Indeterminate
    }
    
    static let screenWidth = UIScreen.mainScreen().bounds.width;
    static let screenHeight = UIScreen.mainScreen().bounds.height;
    static let bgColor = UIColor.init(red: 237.0/255.0, green: 237.0/255.0, blue: 237.0/255.0, alpha: 1.0);
    static let allTintColor = UIColor.init(red: 35/255.0, green: 187/255.0, blue: 119/255.0, alpha: 1.0);
    static let lineColor =  UIColor.init(red: 216.0/255.0, green: 216.0/255.0, blue: 216.0/255.0, alpha: 1.0);
    static let selectedCellColor = UIColor.init(red: 243/255.0, green: 243/255.0, blue: 243/255.0, alpha: 1.0)
    static let grayTextColor = Utils.colorWith(154, G: 154, B: 154)
    static let gridItemAspectRatio: CGFloat = 80 / 180.0
    static let keyWindow = UIApplication.sharedApplication().keyWindow!
    // userDefaultKey
    static let KUserKey = "KUserKey"
    static let KPasswordKey = "KPasswordKey"
    static let KTokenKey = "KTokenKey"
    static let KUserIdKey = "KUserIdKey"
    
    static let categoryListCachePath = NSHomeDirectory().stringByAppendingString("/tmp/categoryListCache")
    static let placeListCachePath = NSHomeDirectory().stringByAppendingString("/tmp/placeListCache")
    static let courseListCachePath = NSHomeDirectory().stringByAppendingString("/tmp/courseListCache")
    static let teacherListCachePath = NSHomeDirectory().stringByAppendingString("/tmp/teacherListCache")
    
    class func colorWith(R: CGFloat, G:CGFloat, B: CGFloat) -> UIColor {
        return UIColor.init(red: R / 255.0, green: G / 255.0, blue: B / 255.0, alpha: 1.0)
    }
    
    class func layoutViewControllerFromTop(vc: UIViewController) {
        vc.navigationController?.navigationBar.translucent = false
        vc.extendedLayoutIncludesOpaqueBars = true
        vc.automaticallyAdjustsScrollViewInsets = false
    }
    
    class func optionalStringIsValid(string: String?) -> Bool {
        var isValid = false
        if let text = string {
            isValid = !text.isEmpty
        }
        return isValid
    }

    // UserDefault
    class func userDefalutSaved(obj: AnyObject?, key: String) {
        NSUserDefaults.standardUserDefaults().setObject(obj, forKey: key)
    }
    
    class func userDefaultDelete(key: String) {
        NSUserDefaults.standardUserDefaults().delete(userDefaultGet(key))
    }
    
    class func userDefaultGet(key: String) -> AnyObject? {
        return NSUserDefaults.standardUserDefaults().objectForKey(key)
    }
    
    // 正则
    class func validateMobile(mobile: String) -> Bool {
        let phoneRegex = "^1((3|5|7|8)\\d)\\d{8}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@",phoneRegex)
        return phoneTest.evaluateWithObject(mobile)
    }
    
    class func validateEmailAdress(email: String) -> Bool {
        let emailPattern = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@",emailPattern)
        return emailTest.evaluateWithObject(email)
    }
    //最多保留两位小数
    class func validateNumber(number:String) -> Bool{
        let numberPattern = "^[0-9]+(.[0-9]{1,2})?$"
        let numberTest = NSPredicate(format: "SELF MATCHES %@",numberPattern)
        return numberTest.evaluateWithObject(number)
    }
    
    
    static var currentView: UIView {
        get {
            var controller = UIApplication.sharedApplication().keyWindow?.rootViewController
            
            if controller == nil {
                return UIApplication.sharedApplication().keyWindow!
            }
            
            if controller!.isKindOfClass(UITabBarController.self) {
                controller = (controller as! UITabBarController).selectedViewController
            }else if controller!.isKindOfClass(UINavigationController.self) {
                controller = (controller as! UINavigationController).visibleViewController
            }else {
                return UIApplication.sharedApplication().keyWindow!
            }
            
            return controller!.view;
        }
    }
    
    class func showHUDWithMessage(message: String,time:NSTimeInterval,block:MBProgressHUDCompletionBlock) {
        let duration: NSTimeInterval = time
        let hud = MBProgressHUD.showHUDAddedTo(currentView, animated: true)
        hud.mode = .Text
        hud.label.text = message
        hud.completionBlock = block
        hud.hideAnimated(true, afterDelay: duration)
    }
    
    /**
        判断字符串是否为空，如果不为空，则返回字符串
     */
    class func isNullString(string:String) -> (Bool,String){
        var str = string
        str = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if str == "" {
            return (true,"")
        }else{
            return (false,str)
        }
    }
}
