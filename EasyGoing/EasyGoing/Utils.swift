//
//  Utils.swift
//  eiisys讲堂
//
//  Created by tanghy on 16/5/23.
//  Copyright © 2016年 tanghy. All rights reserved.
//

import UIKit
import MBProgressHUD
import SAMKeychain
import JCAlertView

typealias completeBlock = () -> Void

class Utils: NSObject{
    
    //单例模式的Utils工具类
    static let sharedInstance = Utils()
    private override init() {}
    
    
    //MARK:根据屏幕大小计算尺寸
    class func scale(size:CGFloat) -> Int{
        return Int((size/414.0) * UIScreen.mainScreen().bounds.width)
    }
    
    class func scaleFloat(size:CGFloat) -> CGFloat{
        return (size/414.0) * UIScreen.mainScreen().bounds.width
    }
    
    static let screenWidth = UIScreen.mainScreen().bounds.width;
    static let screenHeight = UIScreen.mainScreen().bounds.height;
    
    static let coverColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.4)
    static let bgColor = UIColor.init(red: 237.0/255.0, green: 237.0/255.0, blue: 237.0/255.0, alpha: 1.0);
    static let allTintColor = UIColor.init(red: 35/255.0, green: 187/255.0, blue: 119/255.0, alpha: 1.0);//23BB77
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
    
    //MARK:弹框部分
    //MARK:文本消息提示框
    class func showHUDWithMessage(message: String,time:NSTimeInterval,block:MBProgressHUDCompletionBlock) {
        let duration: NSTimeInterval = time
        let hud = MBProgressHUD.showHUDAddedTo(currentView, animated: true)
        hud.mode = .Text
        hud.label.text = message
        hud.completionBlock = block
        hud.hideAnimated(true, afterDelay: duration)
    }
    
    class func showMessageOnView(view:UIView, message: String, time:NSTimeInterval,block:MBProgressHUDCompletionBlock?){
        let duration: NSTimeInterval = time
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.mode = .Text
        hud.label.text = message
        hud.completionBlock = block
        hud.hideAnimated(true, afterDelay: duration)
    }
    
    //MARK:加载视图提示框
    var hud:MBProgressHUD?
    func showLoadingView(msg:String){
        hud = MBProgressHUD.showHUDAddedTo(Utils.currentView, animated: true)
        hud!.mode = .Text
        hud!.label.text = msg + "..."
        hud!.mode = .Indeterminate
    }
    
    func showLoadingViewOnView(msg:String, parentView:UIView){
        hud = MBProgressHUD.showHUDAddedTo(parentView, animated: true)
        hud!.mode = .Text
        hud!.label.text = msg + "..."
        hud!.mode = .Indeterminate
    }
    
    //MARK:取消加载视图
    func hideLoadingView(){
        if hud != nil {
            hud!.hideAnimated(false)
            hud = nil
        }
    }
    
    var glassHour:FeHourGlass?
    var glassHourParentView:UIView?
    //MARK:显示SettingsController加载视图
    func showHourGlassOnView(parentView:UIView){
        if glassHour != nil {
            glassHour?.removeFromSuperview()
            glassHour = nil
        }
        glassHour = FeHourGlass.init(view: parentView)
        glassHourParentView = parentView
        parentView.addSubview(glassHour!)
        glassHour?.show()
    }
    
    //MARK:取消SettingsController加载视图
    func hideHourGlass() {
        if glassHour != nil {
            glassHour?.removeFromSuperview()
            glassHour = nil
        }
    }
    
    //MARK:JCAlert提示框
    class func showJCAlert(tipTitle:String, tips:String, complete:completeBlock) {
        
        //删除提示
        let msg = tips
        let msgHeight = Utils.heightForText(msg, size: CGSizeMake(CGFloat(Utils.scale(300)), CGFloat.max), font: UIFont.systemFontOfSize(17))
        
        //视图总高度 = 标题顶部15 + 标题高度20 + 提示信息顶部15 + 提示信息高度 + 按钮顶部15 + 按钮高度45 + 顶部空白15
        let alertViewHeight:CGFloat = 15 + 20 + 15 + msgHeight + 15 + 45 + 15
        //删除视图
        let alertView = UIView.init(frame: CGRectMake(0, 0, CGFloat(Utils.scale(320)), alertViewHeight))
        alertView.backgroundColor = Utils.bgColor
        
        //初始化弹窗视图
        let jcAlert = JCAlertView.init(customView: alertView, dismissWhenTouchedBackground: true)
        
        //标题
        let titleView = UILabel()
        titleView.text = tipTitle
        titleView.textAlignment = .Center
        titleView.font = UIFont.systemFontOfSize(17)
        titleView.textColor = UIColor.blackColor()
        alertView.addSubview(titleView)
        titleView.snp_makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
        }
        //提示信息
        let msgLable = UILabel()
        msgLable.textColor = UIColor.blackColor()
        msgLable.text = msg
        alertView.addSubview(msgLable)
        msgLable.numberOfLines = 0
        msgLable.snp_makeConstraints { (make) in
            make.top.equalTo(titleView.snp_bottom).offset(15)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        //取消按钮
        let cancelButton = UIButton()
        cancelButton.setTitle("取消", forState: .Normal)
        cancelButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
        cancelButton.backgroundColor = UIColor.whiteColor()
        cancelButton.bk_addEventHandler({ (btn) in
            //关闭弹窗
            jcAlert.dismissWithCompletion({})
            }, forControlEvents: .TouchUpInside)
        alertView.addSubview(cancelButton)
        cancelButton.snp_makeConstraints { (make) in
            make.top.equalTo(msgLable.snp_bottom).offset(15)
            make.left.equalTo(10)
            make.width.equalTo(Utils.scale(140))
            make.height.equalTo(Utils.scale(45))
        }
        
        //确定按钮
        let closeButton = UIButton()
        closeButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        closeButton.setTitle("确定", forState: .Normal)
        closeButton.backgroundColor = Utils.allTintColor
        alertView.addSubview(closeButton)
        closeButton.snp_makeConstraints { (make) in
            make.top.equalTo(msgLable.snp_bottom).offset(15)
            make.right.equalTo(-10)
            make.width.equalTo(Utils.scale(140))
            make.height.equalTo(Utils.scale(45))
        }
        closeButton.bk_addEventHandler({ (button) in
            //关闭弹窗
            jcAlert.dismissWithCompletion(nil)
            //回调块
            complete()
        }, forControlEvents: .TouchUpInside)
        //弹出视图
        //调用jcAlert弹窗
//        self.jcAlert = JCAlertView.init(customView: alertView, dismissWhenTouchedBackground: true)
        jcAlert.show()
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
    
    /**
        计算文本的高度
     */
    class func heightForText(text:NSString,size:CGSize,font:UIFont) ->CGFloat{
        let textSize = text.boundingRectWithSize(size, options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName:font], context: nil).size
        return textSize.height
    }
    
    class func widthForText(text:NSString,size:CGSize,font:UIFont) -> CGFloat{
        let textSize = text.boundingRectWithSize(size, options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName:font], context: nil).size
        return textSize.width
    }
    
    //MARK:TimeLine
    /**消费项目类别的数据源*/
    static var eventDataSource:[TimeLineEvent]?

}
